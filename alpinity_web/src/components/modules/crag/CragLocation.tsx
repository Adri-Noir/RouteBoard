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
  const markersRef = useRef<{ [key: string]: mapboxgl.Marker }>({});

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

    return () => {
      if (map.current) {
        map.current.remove();
        map.current = null;
      }
    };
  }, [location, location.latitude, location.longitude, sectors]);

  // Handle sector markers separately
  useEffect(() => {
    if (!map.current || !sectors.length) return;

    // Clear existing markers
    Object.values(markersRef.current).forEach((marker) => marker.remove());
    markersRef.current = {};

    // Add sector markers
    sectors.forEach((sector) => {
      if (!sector.id) return;

      const sectorEl = document.createElement("div");
      sectorEl.className = "marker";
      sectorEl.style.width = "32px";
      sectorEl.style.height = "32px";
      sectorEl.style.borderRadius = "50%";
      sectorEl.style.display = "flex";
      sectorEl.style.alignItems = "center";
      sectorEl.style.justifyContent = "center";
      sectorEl.style.border = "2px solid white";
      sectorEl.style.boxShadow = "0 2px 6px rgba(0,0,0,0.25)";

      // Change background color based on selection state
      const backgroundColor = sector.id === selectedSectorId ? "#22c55e" : "#2563eb";
      sectorEl.style.backgroundColor = backgroundColor;

      // Add the brick wall icon inside
      sectorEl.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M12 9v6"/><path d="M16 15v6"/><path d="M16 3v6"/><path d="M3 15h18"/><path d="M3 9h18"/><path d="M8 15v6"/><path d="M8 3v6"/></svg>`;

      // Make the marker clickable if it has an id and onSectorClick is provided
      if (onSectorClick) {
        sectorEl.style.cursor = "pointer";
        sectorEl.addEventListener("click", () => {
          onSectorClick(sector.id as string);
        });
      }

      const marker = new mapboxgl.Marker(sectorEl).setLngLat([sector.longitude, sector.latitude]).addTo(map.current!);

      markersRef.current[sector.id] = marker;
    });

    return () => {
      Object.values(markersRef.current).forEach((marker) => marker.remove());
      markersRef.current = {};
    };
  }, [sectors, onSectorClick, selectedSectorId]);

  useEffect(() => {
    if (!map.current) return;

    // Update marker colors based on selected state
    Object.entries(markersRef.current).forEach(([id, marker]) => {
      const el = marker.getElement();
      const markerColor = id === selectedSectorId ? "#22c55e" : "#2563eb";
      el.style.backgroundColor = markerColor;
    });
  }, [selectedSectorId]);

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
