"use client";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import ImageWithLoading from "@/components/ui/library/ImageWithLoading/ImageWithLoading";
import { getApiMapGlobeSectorsByCragIdOptions, postApiMapGlobeMutation } from "@/lib/api/@tanstack/react-query.gen";
import { PointDto } from "@/lib/api/types.gen";
import { useDebounce } from "@/lib/hooks/useDebounce";
import { useInteractiveMap } from "@/lib/hooks/useInteractiveMap";
import { useMutation, useQuery } from "@tanstack/react-query";
import { ExternalLink, Grid3X3, MapIcon, MapPin, Maximize2, Minimize2, X } from "lucide-react";
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";
import Link from "next/link";
import { useEffect, useRef, useState } from "react";

// Define a type for crag data matching GlobeResponseDto
interface CragData {
  id?: string;
  name?: string | null;
  imageUrl?: string | null;
  location?: PointDto;
}

// Replace with your actual Mapbox token from env
mapboxgl.accessToken = process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN || "";

const defaultZoom = 14;

// Function to calculate the distance between two points in kilometers
const calculateDistance = (lat1: number, lon1: number, lat2: number, lon2: number): number => {
  const R = 6371; // Earth's radius in kilometers
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

// Function to calculate optimal zoom level based on sector spread
const calculateOptimalZoom = (centerLocation: PointDto, sectors: { location?: PointDto }[]): number => {
  if (!sectors.length) return defaultZoom;

  // Calculate the maximum distance from center to any sector
  let maxDistance = 0;
  sectors.forEach((sector) => {
    if (sector.location?.latitude && sector.location?.longitude) {
      const distance = calculateDistance(
        centerLocation.latitude,
        centerLocation.longitude,
        sector.location.latitude,
        sector.location.longitude,
      );
      maxDistance = Math.max(maxDistance, distance);
    }
  });

  // If all sectors are very close to center, use default zoom
  if (maxDistance < 0.1) return defaultZoom;

  // Calculate zoom level based on maximum distance
  // These values are empirically determined for good visual coverage
  if (maxDistance < 0.5) return 15; // Very close sectors
  if (maxDistance < 1) return 14; // Close sectors
  if (maxDistance < 2) return 13; // Medium distance
  if (maxDistance < 5) return 12; // Default for moderate spread
  if (maxDistance < 10) return 11; // Wider spread
  if (maxDistance < 20) return 10; // Very wide spread
  return 9; // Extremely wide spread
};

export function MapGlobe() {
  const mapContainer = useRef<HTMLDivElement>(null);
  const mapWrapperRef = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);

  const [bounds, setBounds] = useState<{ northEast: PointDto; southWest: PointDto } | null>(null);
  const debouncedBounds = useDebounce(bounds, 500);
  const [selectedCrag, setSelectedCrag] = useState<CragData | null>(null);
  const [isFullScreen, setIsFullScreen] = useState(false);
  const [cachedCrags, setCachedCrags] = useState<CragData[]>([]);

  const { isInteractive, handleActivateMap, handleDeactivateMap } = useInteractiveMap({
    mapRef: map,
    wrapperRef: mapWrapperRef,
  });

  // Fetch crags based on map bounds
  const { mutateAsync: fetchCrags } = useMutation(postApiMapGlobeMutation());

  // Fetch sectors for selected crag
  const { data: sectors, isLoading: isSectorsLoading } = useQuery({
    ...getApiMapGlobeSectorsByCragIdOptions({
      path: { cragId: selectedCrag?.id || "" },
    }),
    enabled: !!selectedCrag?.id,
    refetchOnWindowFocus: false,
  });

  // Initialize map
  useEffect(() => {
    if (!mapContainer.current || map.current) return;
    const newMap = new mapboxgl.Map({
      container: mapContainer.current,
      style: "mapbox://styles/mapbox/outdoors-v12",
      center: [10, 45],
      zoom: 4,
    });

    map.current = newMap;

    // Add navigation controls
    newMap.addControl(new mapboxgl.NavigationControl(), "top-right");

    // Disable map interactions by default
    newMap.dragPan.disable();
    newMap.scrollZoom.disable();
    newMap.boxZoom.disable();
    newMap.dragRotate.disable();
    newMap.keyboard.disable();
    newMap.doubleClickZoom.disable();
    newMap.touchZoomRotate.disable();

    // Initialize the map sources and layers on load
    newMap.on("load", () => {
      const mapBounds = newMap.getBounds();
      if (mapBounds) {
        setBounds({
          northEast: {
            latitude: mapBounds.getNorthEast().lat,
            longitude: mapBounds.getNorthEast().lng,
          },
          southWest: {
            latitude: mapBounds.getSouthWest().lat,
            longitude: mapBounds.getSouthWest().lng,
          },
        });
      }

      // Add source for clusters
      newMap.addSource("crags", {
        type: "geojson",
        data: {
          type: "FeatureCollection",
          features: [],
        },
        cluster: true,
        clusterMaxZoom: 14,
        clusterRadius: 50,
      });

      // Add cluster layer
      newMap.addLayer({
        id: "clusters",
        type: "circle",
        source: "crags",
        filter: ["has", "point_count"],
        paint: {
          "circle-color": [
            "step",
            ["get", "point_count"],
            "#51bbd6", // Small clusters
            10,
            "#f1f075", // Medium clusters
            30,
            "#f28cb1", // Large clusters
          ],
          "circle-radius": [
            "step",
            ["get", "point_count"],
            22, // Radius for small clusters
            10,
            32, // Radius for medium clusters
            30,
            42, // Radius for large clusters
          ],
          "circle-stroke-width": 3,
          "circle-stroke-color": "#ffffff",
          "circle-stroke-opacity": 0.9,
        },
      });

      // Add cluster count labels
      newMap.addLayer({
        id: "cluster-count",
        type: "symbol",
        source: "crags",
        filter: ["has", "point_count"],
        layout: {
          "text-field": "{point_count_abbreviated}",
          "text-font": ["DIN Offc Pro Medium", "Arial Unicode MS Bold"],
          "text-size": 14,
        },
        paint: {
          "text-color": "#ffffff",
        },
      });

      // Add unclustered point layer
      newMap.addLayer({
        id: "unclustered-point",
        type: "symbol",
        source: "crags",
        filter: ["!", ["has", "point_count"]],
        layout: {
          "icon-image": "mountain-marker",
          "icon-size": 1,
          "icon-allow-overlap": true,
        },
      });

      // Add mountain marker image
      const mountainSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40">
        <circle cx="20" cy="20" r="18" fill="#dc2626" stroke="white" stroke-width="3"/>
        <svg x="12" y="12" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="m8 3 4 8 5-5 5 15H2L8 3z"/>
        </svg>
      </svg>`;

      const mountainImg = new Image(40, 40);
      mountainImg.onload = () => {
        if (newMap.hasImage("mountain-marker")) return;
        newMap.addImage("mountain-marker", mountainImg);
      };
      mountainImg.src = `data:image/svg+xml;base64,${btoa(mountainSvg)}`;

      // Add source for sectors
      newMap.addSource("sectors", {
        type: "geojson",
        data: {
          type: "FeatureCollection",
          features: [],
        },
      });

      // Add sector points layer with zoom-dependent visibility
      newMap.addLayer({
        id: "sector-points",
        type: "symbol",
        source: "sectors",
        minzoom: 12, // Only show sectors when zoomed in close enough
        layout: {
          "icon-image": "sector-marker",
          "icon-size": 1,
          "icon-allow-overlap": true,
        },
      });

      // Add sector marker image
      const sectorSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
        <circle cx="16" cy="16" r="14" fill="#2563eb" stroke="white" stroke-width="2"/>
        <svg x="8" y="8" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect width="18" height="18" x="3" y="3" rx="2"/>
          <path d="M12 9v6"/>
          <path d="M16 15v6"/>
          <path d="M16 3v6"/>
          <path d="M3 15h18"/>
          <path d="M3 9h18"/>
          <path d="M8 15v6"/>
          <path d="M8 3v6"/>
        </svg>
      </svg>`;

      const sectorImg = new Image(32, 32);
      sectorImg.onload = () => {
        if (newMap.hasImage("sector-marker")) return;
        newMap.addImage("sector-marker", sectorImg);
      };
      sectorImg.src = `data:image/svg+xml;base64,${btoa(sectorSvg)}`;

      // Add sector labels layer with zoom-dependent visibility
      newMap.addLayer({
        id: "sector-labels",
        type: "symbol",
        source: "sectors",
        minzoom: 12, // Only show sector labels when zoomed in close enough
        layout: {
          "text-field": ["get", "name"],
          "text-font": ["DIN Offc Pro Medium", "Arial Unicode MS Bold"],
          "text-size": 12,
          "text-offset": [0, 1.5],
          "text-anchor": "top",
        },
        paint: {
          "text-color": "#333",
          "text-halo-color": "#fff",
          "text-halo-width": 1,
        },
      });
    });

    return () => {
      if (map.current) {
        map.current.remove();
        map.current = null;
      }
    };
  }, []);

  // Setup map event handlers
  useEffect(() => {
    if (!map.current) return;

    // Click handler for clusters
    const handleClusterClick = (e: mapboxgl.MapMouseEvent) => {
      if (!isInteractive) return;

      const features = map.current?.queryRenderedFeatures(e.point, { layers: ["clusters"] });
      if (!features || features.length === 0) return;

      const clusterId = features[0].properties?.cluster_id;

      const source = map.current?.getSource("crags") as mapboxgl.GeoJSONSource;
      source.getClusterExpansionZoom(clusterId, (err, zoom) => {
        if (err || !map.current) return;

        // Add 1.5 to zoom level to get closer than the default expansion zoom
        const enhancedZoom = Math.min((zoom || 0) + 1.5, 16);

        map.current.easeTo({
          center: (features[0].geometry as GeoJSON.Point).coordinates as [number, number],
          zoom: enhancedZoom,
          duration: 800,
        });
      });
    };

    // Click handler for unclustered points
    const handlePointClick = (e: mapboxgl.MapMouseEvent) => {
      if (!isInteractive) return;

      const features = map.current?.queryRenderedFeatures(e.point, { layers: ["unclustered-point"] });
      if (!features || features.length === 0) return;

      const feature = features[0];
      const { id, name, imageUrl } = feature.properties || {};
      const coordinates = (feature.geometry as GeoJSON.Point).coordinates as [number, number];

      if (id) {
        // Store the complete crag data
        setSelectedCrag({
          id,
          name,
          imageUrl,
          location: {
            longitude: coordinates[0],
            latitude: coordinates[1],
          },
        });
      }
    };

    // Cursor handlers
    const handleClusterMouseEnter = () => {
      if (isInteractive && map.current) {
        map.current.getCanvas().style.cursor = "pointer";
      }
    };

    const handleClusterMouseLeave = () => {
      if (map.current) {
        map.current.getCanvas().style.cursor = "";
      }
    };

    const handlePointMouseEnter = () => {
      if (isInteractive && map.current) {
        map.current.getCanvas().style.cursor = "pointer";
      }
    };

    const handlePointMouseLeave = () => {
      if (map.current) {
        map.current.getCanvas().style.cursor = "";
      }
    };

    // Map move handler
    const handleMoveEnd = () => {
      if (!map.current) return;

      const mapBounds = map.current.getBounds();
      if (mapBounds) {
        setBounds({
          northEast: {
            latitude: mapBounds.getNorthEast().lat,
            longitude: mapBounds.getNorthEast().lng,
          },
          southWest: {
            latitude: mapBounds.getSouthWest().lat,
            longitude: mapBounds.getSouthWest().lng,
          },
        });
      }
    };

    // Register event handlers
    map.current.on("click", "clusters", handleClusterClick);
    map.current.on("click", "unclustered-point", handlePointClick);
    map.current.on("mouseenter", "clusters", handleClusterMouseEnter);
    map.current.on("mouseleave", "clusters", handleClusterMouseLeave);
    map.current.on("mouseenter", "unclustered-point", handlePointMouseEnter);
    map.current.on("mouseleave", "unclustered-point", handlePointMouseLeave);
    map.current.on("moveend", handleMoveEnd);

    // Cleanup event handlers
    return () => {
      if (!map.current) return;

      map.current.off("click", "clusters", handleClusterClick);
      map.current.off("click", "unclustered-point", handlePointClick);
      map.current.off("mouseenter", "clusters", handleClusterMouseEnter);
      map.current.off("mouseleave", "clusters", handleClusterMouseLeave);
      map.current.off("mouseenter", "unclustered-point", handlePointMouseEnter);
      map.current.off("mouseleave", "unclustered-point", handlePointMouseLeave);
      map.current.off("moveend", handleMoveEnd);
    };
  }, [isInteractive]);

  // Separate effect to zoom to selected crag when it changes
  useEffect(() => {
    if (!map.current || !selectedCrag || !selectedCrag.location) return;

    if (!sectors || !sectors.length)
      map.current.flyTo({
        center: [selectedCrag.location.longitude, selectedCrag.location.latitude],
        zoom: defaultZoom,
        duration: 1000,
      });

    const optimalZoom = calculateOptimalZoom(selectedCrag.location, sectors || []);

    map.current.flyTo({
      center: [selectedCrag.location.longitude, selectedCrag.location.latitude],
      zoom: Math.min(optimalZoom + 1, 16),
      duration: 1000,
    });
  }, [selectedCrag, sectors]);

  // Update map interactivity when isInteractive changes
  useEffect(() => {
    if (!map.current) return;

    // Update cursor style for interactive map features
    const updateCursorStyle = () => {
      const clusters = document.querySelectorAll(".mapboxgl-canvas-container");
      clusters.forEach((cluster) => {
        if (isInteractive) {
          cluster.classList.add("interactive");
        } else {
          cluster.classList.remove("interactive");
        }
      });
    };

    updateCursorStyle();
  }, [isInteractive]);

  // Fetch crags when bounds change and update cache
  useEffect(() => {
    const getCrags = async () => {
      if (!debouncedBounds) return;

      try {
        const cragsData = await fetchCrags({
          body: {
            northEast: debouncedBounds.northEast,
            southWest: debouncedBounds.southWest,
          },
        });

        const newCrags = cragsData.filter((crag) => !cachedCrags.some((c) => c.id === crag.id));

        if (newCrags.length === 0) return;

        // Merge new crags with cached crags, avoiding duplicates
        setCachedCrags((prevCrags) => {
          const newCragsMap = new Map<string, CragData>();

          // Add existing crags to map
          prevCrags.forEach((crag) => {
            if (crag.id) {
              newCragsMap.set(crag.id, crag);
            }
          });

          // Add new crags to map
          cragsData.forEach((crag) => {
            if (crag.id) {
              newCragsMap.set(crag.id, crag);
            }
          });

          return Array.from(newCragsMap.values());
        });
      } catch (error) {
        console.error("Error fetching crags:", error);
      }
    };

    getCrags();
  }, [debouncedBounds, fetchCrags, cachedCrags]);

  // Update map with cached crags
  useEffect(() => {
    if (!map.current || cachedCrags.length === 0) return;

    // Update map source with cached data
    const source = map.current.getSource("crags") as mapboxgl.GeoJSONSource;

    if (source) {
      source.setData({
        type: "FeatureCollection",
        features: cachedCrags
          .filter((crag) => crag.location?.latitude && crag.location?.longitude)
          .map((crag) => ({
            type: "Feature",
            geometry: {
              type: "Point",
              coordinates: [crag.location?.longitude || 0, crag.location?.latitude || 0],
            },
            properties: {
              id: crag.id,
              name: crag.name || "Unnamed Crag",
              imageUrl: crag.imageUrl || "",
            },
          })),
      });
    }
  }, [cachedCrags]);

  // Add sector markers when sectors are loaded, and handle zoom change
  useEffect(() => {
    if (!map.current || !sectors || isSectorsLoading) return;

    // Skip if the source is not yet available
    const source = map.current.getSource("sectors") as mapboxgl.GeoJSONSource;
    if (!source) return;

    // Update the source data with the sectors
    source.setData({
      type: "FeatureCollection",
      features: sectors
        .filter((sector) => sector.location?.latitude && sector.location?.longitude)
        .map((sector) => ({
          type: "Feature",
          geometry: {
            type: "Point",
            coordinates: [sector.location?.longitude || 0, sector.location?.latitude || 0],
          },
          properties: {
            id: sector.id,
            name: sector.name || "Unnamed Sector",
            imageUrl: sector.imageUrl || "",
          },
        })),
    });

    // Setup popup for sectors
    const popup = new mapboxgl.Popup({
      closeButton: false,
      closeOnClick: false,
      offset: 15,
    });

    // Add hover effect for sectors, only when zoomed in enough
    const handleMouseEnter = (e: mapboxgl.MapMouseEvent) => {
      if (!map.current) return;

      // Only show cursor and popup if we're zoomed in enough
      if (map.current.getZoom() < 12) return;

      map.current.getCanvas().style.cursor = "pointer";

      if (e.features && e.features.length > 0) {
        const feature = e.features[0];
        const coordinates = (feature.geometry as GeoJSON.Point).coordinates.slice() as [number, number];
        const name = feature.properties?.name || "Unnamed Sector";
        const imageUrl = feature.properties?.imageUrl;

        // Contents for the popup
        let popupContent = `<div class="p-2"><strong>${name}</strong>`;
        if (imageUrl) {
          popupContent += `<div class="mt-1"><img src="${imageUrl}" alt="${name}" class="w-full h-20 object-cover rounded" /></div>`;
        }
        popupContent += `</div>`;

        popup.setLngLat(coordinates).setHTML(popupContent).addTo(map.current);
      }
    };

    const handleMouseLeave = () => {
      if (!map.current) return;
      map.current.getCanvas().style.cursor = "";
      popup.remove();
    };

    map.current.on("mouseenter", "sector-points", handleMouseEnter);
    map.current.on("mouseleave", "sector-points", handleMouseLeave);

    return () => {
      if (map.current) {
        map.current.off("mouseenter", "sector-points", handleMouseEnter);
        map.current.off("mouseleave", "sector-points", handleMouseLeave);
        popup.remove();
      }
    };
  }, [sectors, isSectorsLoading]);

  // Toggle fullscreen mode
  const toggleFullScreen = () => {
    setIsFullScreen(!isFullScreen);

    // Let the map know it was resized after the animation completes
    setTimeout(() => {
      if (map.current) {
        map.current.resize();
      }
    }, 300);
  };

  return (
    <div
      className={`relative transition-all duration-300 ${isFullScreen ? "bg-background fixed inset-0 z-50 p-4" : ""}`}
      ref={mapWrapperRef}
    >
      <div
        ref={mapContainer}
        className={`overflow-hidden rounded-md border ${isFullScreen ? "h-[calc(75vh-2rem)]" : "h-[600px]"}`}
      />

      {/* Crag detail panel */}
      {isInteractive && selectedCrag && (
        <div className="absolute bottom-4 left-1/2 w-full max-w-sm -translate-x-1/2 transform px-4 transition-all duration-300">
          <Card className="bg-background/95 border shadow-xl backdrop-blur-sm">
            <CardHeader className="pb-3">
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0 flex-1">
                  <Link href={`/crag/${selectedCrag.id}`} className="group">
                    <h3 className="group-hover:text-primary text-lg leading-tight font-semibold transition-colors">
                      {selectedCrag.name || "Unnamed Crag"}
                    </h3>
                  </Link>
                  {selectedCrag.location && (
                    <div className="text-muted-foreground mt-1 flex items-center gap-1 text-sm">
                      <MapPin className="h-3 w-3" />
                      <span>
                        {selectedCrag.location.latitude.toFixed(4)}, {selectedCrag.location.longitude.toFixed(4)}
                      </span>
                    </div>
                  )}
                </div>
                <Button variant="ghost" size="icon" className="h-8 w-8 shrink-0" onClick={() => setSelectedCrag(null)}>
                  <X className="h-4 w-4" />
                </Button>
              </div>
            </CardHeader>

            <CardContent className="pt-0">
              {selectedCrag.imageUrl && (
                <div className="mb-4">
                  <ImageWithLoading
                    src={selectedCrag.imageUrl}
                    alt={selectedCrag.name || "Crag image"}
                    className="w-full rounded-lg object-cover"
                    width={400}
                    height={200}
                    containerClassName="w-full h-32 overflow-hidden rounded-lg"
                  />
                </div>
              )}

              {/* Sectors section */}
              <div className="space-y-3">
                {sectors && sectors.length > 0 ? (
                  <>
                    <div className="flex items-center gap-2">
                      <Grid3X3 className="text-muted-foreground h-4 w-4" />
                      <span className="text-sm font-medium">
                        {sectors.length} {sectors.length === 1 ? "Sector" : "Sectors"}
                      </span>
                    </div>
                    <div className="flex flex-wrap gap-1.5">
                      {sectors.slice(0, 6).map((sector) => (
                        <Link
                          key={sector.id}
                          href={`/crag/${selectedCrag.id}?sectorId=${sector.id}`}
                          className="transition-transform hover:scale-105"
                        >
                          <Badge
                            variant="secondary"
                            className="hover:bg-secondary/80 cursor-pointer px-2 py-1 text-xs font-normal transition-colors"
                          >
                            {sector.name || "Unnamed"}
                          </Badge>
                        </Link>
                      ))}
                      {sectors.length > 6 && (
                        <Badge variant="outline" className="px-2 py-1 text-xs font-normal">
                          +{sectors.length - 6} more
                        </Badge>
                      )}
                    </div>
                  </>
                ) : (
                  <div className="text-muted-foreground flex items-center gap-2">
                    <Grid3X3 className="h-4 w-4" />
                    <span className="text-sm">{isSectorsLoading ? "Loading sectors..." : "No sectors available"}</span>
                  </div>
                )}
              </div>

              {/* Action buttons */}
              <div className="mt-4 flex gap-2 border-t pt-3">
                <Button asChild size="sm" className="flex-1">
                  <Link href={`/crag/${selectedCrag.id}`}>
                    <ExternalLink className="mr-1.5 h-3 w-3" />
                    View Details
                  </Link>
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {!isInteractive && (
        <div
          className="absolute inset-0 flex cursor-pointer items-center justify-center rounded-md bg-black/40 transition-opacity"
          onClick={handleActivateMap}
        >
          <div className="bg-background/90 rounded-md px-4 py-2 shadow-md">
            <p className="text-foreground font-medium">Click to activate map</p>
          </div>
        </div>
      )}

      {isInteractive && (
        <div className="absolute top-4 left-4 flex gap-2 space-y-2">
          <Button variant="outline" size="icon" onClick={toggleFullScreen} className="bg-background rounded-full">
            {isFullScreen ? <Minimize2 className="h-4 w-4" /> : <Maximize2 className="h-4 w-4" />}
          </Button>

          <Button variant="outline" size="icon" onClick={handleDeactivateMap} className="bg-background rounded-full">
            <MapIcon className="h-4 w-4" />
          </Button>
        </div>
      )}
    </div>
  );
}
