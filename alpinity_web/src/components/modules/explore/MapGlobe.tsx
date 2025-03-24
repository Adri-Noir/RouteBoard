"use client";

import { Button } from "@/components/ui/button";
import { getApiMapGlobeSectorsByCragIdOptions, postApiMapGlobeMutation } from "@/lib/api/@tanstack/react-query.gen";
import { PointDto } from "@/lib/api/types.gen";
import { useDebounce } from "@/lib/hooks/useDebounce";
import { useInteractiveMap } from "@/lib/hooks/useInteractiveMap";
import { useMutation, useQuery } from "@tanstack/react-query";
import { MapIcon, Maximize2, Minimize2, X } from "lucide-react";
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";
import Image from "next/image";
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
        type: "circle",
        source: "crags",
        filter: ["!", ["has", "point_count"]],
        paint: {
          "circle-color": "#11b4da",
          "circle-radius": 10,
          "circle-stroke-width": 2,
          "circle-stroke-color": "#ffffff",
        },
      });

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
        type: "circle",
        source: "sectors",
        minzoom: 12, // Only show sectors when zoomed in close enough
        paint: {
          "circle-radius": 6,
          "circle-color": "#f28cb1",
          "circle-stroke-width": 2,
          "circle-stroke-color": "#ffffff",
        },
      });

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

    // Zoom to the crag
    map.current.flyTo({
      center: [selectedCrag.location.longitude, selectedCrag.location.latitude],
      zoom: 14,
      duration: 1000,
    });
  }, [selectedCrag]);

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
        <div
          className="bg-background/95 absolute bottom-4 left-1/2 w-auto max-w-md -translate-x-1/2 transform overflow-hidden rounded-md border
            shadow-lg transition-all duration-300"
        >
          <div className="p-4">
            <div className="mb-2 flex items-center justify-between">
              <Link href={`/crag/${selectedCrag.id}`}>
                <h3 className="text-lg font-semibold hover:underline">{selectedCrag.name || "Unnamed Crag"}</h3>
              </Link>
              <Button variant="ghost" size="icon" className="h-6 w-6" onClick={() => setSelectedCrag(null)}>
                <X className="h-4 w-4" />
              </Button>
            </div>

            {selectedCrag.imageUrl && (
              <div className="mb-3">
                <Image
                  src={selectedCrag.imageUrl}
                  alt={selectedCrag.name || "Crag image"}
                  className="rounded-md object-cover"
                  width={100}
                  height={100}
                />
              </div>
            )}

            {sectors && sectors.length > 0 ? (
              <div>
                <p className="text-muted-foreground mb-2 text-sm">This crag has {sectors.length} sectors</p>
                <div className="flex flex-wrap gap-2">
                  {sectors.slice(0, 5).map((sector) => (
                    <div key={sector.id} className="bg-muted text-muted-foreground rounded-full px-2 py-1 text-xs">
                      {sector.name || "Unnamed sector"}
                    </div>
                  ))}
                  {sectors.length > 5 && (
                    <div className="bg-muted text-muted-foreground rounded-full px-2 py-1 text-xs">
                      +{sectors.length - 5} more
                    </div>
                  )}
                </div>
              </div>
            ) : (
              <p className="text-muted-foreground text-sm">Loading sectors...</p>
            )}
          </div>
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
        <div className="absolute top-4 right-4 space-y-2">
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
