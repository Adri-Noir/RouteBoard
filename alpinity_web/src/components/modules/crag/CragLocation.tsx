"use client";

import { Button } from "@/components/ui/button";
import { PointDto } from "@/lib/api/types.gen";
import { useInteractiveMap } from "@/lib/hooks/useInteractiveMap";
import { MapPin } from "lucide-react";
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";
import { useEffect, useRef } from "react";

mapboxgl.accessToken = process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN || "";

const defaultZoom = 12;

interface LocationWithId extends PointDto {
  id?: string;
  name?: string;
}

interface CragLocationProps {
  location: PointDto;
  sectors?: LocationWithId[];
  selectedSectorId?: string;
  onSectorClick?: (sectorId: string) => void;
}

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
const calculateOptimalZoom = (centerLocation: PointDto, sectors: LocationWithId[]): number => {
  if (!sectors.length) return defaultZoom;

  // Calculate the maximum distance from center to any sector
  let maxDistance = 0;
  sectors.forEach((sector) => {
    const distance = calculateDistance(
      centerLocation.latitude,
      centerLocation.longitude,
      sector.latitude,
      sector.longitude,
    );
    maxDistance = Math.max(maxDistance, distance);
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

const CragLocation = ({ location, sectors = [], onSectorClick, selectedSectorId }: CragLocationProps) => {
  const mapContainer = useRef<HTMLDivElement>(null);
  const mapWrapperRef = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);

  const { isInteractive, handleActivateMap, handleDeactivateMap } = useInteractiveMap({
    mapRef: map,
    wrapperRef: mapWrapperRef,
  });

  // Function to recenter the map to the main crag location
  const handleRecenter = () => {
    if (map.current) {
      const optimalZoom = calculateOptimalZoom(location, sectors);
      map.current.flyTo({
        center: [location.longitude, location.latitude],
        zoom: optimalZoom,
        duration: 1000,
      });
    }
  };

  // Initialize map only once
  useEffect(() => {
    if (!mapContainer.current || map.current) return;

    const optimalZoom = calculateOptimalZoom(location, sectors);

    const newMap = new mapboxgl.Map({
      container: mapContainer.current,
      style: "mapbox://styles/mapbox/outdoors-v12",
      center: [location.longitude, location.latitude],
      zoom: optimalZoom,
    });

    map.current = newMap;

    // Add navigation controls
    newMap.addControl(new mapboxgl.NavigationControl(), "top-right");

    // Disable all interaction initially
    newMap.dragPan.disable();
    newMap.scrollZoom.disable();
    newMap.boxZoom.disable();
    newMap.dragRotate.disable();
    newMap.keyboard.disable();
    newMap.doubleClickZoom.disable();
    newMap.touchZoomRotate.disable();

    newMap.on("load", () => {
      // Create a marker element for the main location
      const el = document.createElement("div");
      el.className = "marker";
      el.style.width = "40px";
      el.style.height = "40px";
      el.style.borderRadius = "50%";
      el.style.backgroundColor = "#dc2626";
      el.style.display = "flex";
      el.style.alignItems = "center";
      el.style.justifyContent = "center";
      el.style.border = "3px solid white";
      el.style.boxShadow = "0 2px 8px rgba(0,0,0,0.3)";

      // Add the mountain icon inside
      el.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m8 3 4 8 5-5 5 15H2L8 3z"/></svg>`;

      // Add the main marker
      new mapboxgl.Marker(el).setLngLat([location.longitude, location.latitude]).addTo(newMap);

      // Add source for sectors
      newMap.addSource("sectors", {
        type: "geojson",
        data: {
          type: "FeatureCollection",
          features: [],
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

      // Add selected sector marker image (green)
      const selectedSectorSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
        <circle cx="16" cy="16" r="14" fill="#22c55e" stroke="white" stroke-width="2"/>
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

      const selectedSectorImg = new Image(32, 32);
      selectedSectorImg.onload = () => {
        if (newMap.hasImage("selected-sector-marker")) return;
        newMap.addImage("selected-sector-marker", selectedSectorImg);
      };
      selectedSectorImg.src = `data:image/svg+xml;base64,${btoa(selectedSectorSvg)}`;

      // Add sector points layer
      newMap.addLayer({
        id: "sector-points",
        type: "symbol",
        source: "sectors",
        layout: {
          "icon-image": ["case", ["==", ["get", "selected"], true], "selected-sector-marker", "sector-marker"],
          "icon-size": 1,
          "icon-allow-overlap": true,
        },
      });

      // Add sector labels layer
      newMap.addLayer({
        id: "sector-labels",
        type: "symbol",
        source: "sectors",
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

      // Add click handler for sectors
      if (onSectorClick) {
        newMap.on("click", "sector-points", (e) => {
          if (!isInteractive) return;

          const features = e.features;
          if (features && features.length > 0) {
            const sectorId = features[0].properties?.id;
            if (sectorId) {
              onSectorClick(sectorId);
            }
          }
        });

        // Add cursor pointer on hover
        newMap.on("mouseenter", "sector-points", () => {
          if (isInteractive) {
            newMap.getCanvas().style.cursor = "pointer";
          }
        });

        newMap.on("mouseleave", "sector-points", () => {
          newMap.getCanvas().style.cursor = "";
        });
      }
    });

    return () => {
      if (map.current) {
        map.current.remove();
        map.current = null;
      }
    };
  }, [location, location.latitude, location.longitude, sectors, onSectorClick, isInteractive]);

  // Update sector data when sectors or selectedSectorId changes
  useEffect(() => {
    if (!map.current || !sectors.length) return;

    const source = map.current.getSource("sectors") as mapboxgl.GeoJSONSource;
    if (!source) return;

    // Update the source data with the sectors
    source.setData({
      type: "FeatureCollection",
      features: sectors
        .filter((sector) => sector.latitude && sector.longitude)
        .map((sector) => ({
          type: "Feature",
          geometry: {
            type: "Point",
            coordinates: [sector.longitude, sector.latitude],
          },
          properties: {
            id: sector.id,
            name: sector.name || "Unnamed",
            selected: sector.id === selectedSectorId,
          },
        })),
    });
  }, [sectors, selectedSectorId]);

  return (
    <div className="relative space-y-4" ref={mapWrapperRef}>
      <div ref={mapContainer} className="bg-muted h-[400px] overflow-hidden rounded-md border" />

      {!isInteractive && (
        <div
          onClick={handleActivateMap}
          className="absolute inset-0 flex cursor-pointer items-center justify-center rounded-md bg-black/40 transition-opacity"
        >
          <div className="bg-background/90 rounded-md px-4 py-2 shadow-md">
            <p className="text-foreground font-medium">Click to activate map</p>
          </div>
        </div>
      )}

      {isInteractive && (
        <>
          <Button onClick={handleDeactivateMap} variant="secondary" size="sm" className="absolute top-2 right-14 z-10">
            Exit
          </Button>
          <Button
            onClick={handleRecenter}
            variant="secondary"
            size="sm"
            className="absolute top-2 left-2 z-10 flex items-center gap-2"
            title="Recenter map"
          >
            <MapPin className="h-4 w-4" />
            Recenter
          </Button>
        </>
      )}
    </div>
  );
};

export default CragLocation;
