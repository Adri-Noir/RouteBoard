"use client";

import { PointDto } from "@/lib/api/types.gen";
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";
import { useEffect, useRef } from "react";

// You need to replace this with your actual Mapbox access token
// Get one from https://account.mapbox.com/
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

const CragLocation = ({ location, sectors = [], onSectorClick, selectedSectorId }: CragLocationProps) => {
  const mapContainer = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);
  const markersRef = useRef<{ [key: string]: mapboxgl.Marker }>({});

  // Initialize map only once
  useEffect(() => {
    if (!mapContainer.current || map.current) return;

    const newMap = new mapboxgl.Map({
      container: mapContainer.current,
      style: "mapbox://styles/mapbox/outdoors-v12",
      center: [location.longitude, location.latitude],
      zoom: defaultZoom,
    });

    map.current = newMap;

    // Add navigation controls
    newMap.addControl(new mapboxgl.NavigationControl(), "top-right");

    // Create a marker element for the main location
    const el = document.createElement("div");
    el.className = "marker";
    el.style.width = "30px";
    el.style.height = "30px";
    el.style.backgroundSize = "100%";

    // Crag marker styling (mountain icon with red color)
    el.style.backgroundImage = `url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23dc2626' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m2 22 10-20 10 20M4 22l8-16 8 16M6.38 22l5.55-11.36L17.52 22'/%3E%3C/svg%3E")`;

    // Add the main marker
    new mapboxgl.Marker(el).setLngLat([location.longitude, location.latitude]).addTo(newMap);

    return () => {
      if (map.current) {
        map.current.remove();
        map.current = null;
      }
    };
  }, [location.latitude, location.longitude]);

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
      sectorEl.style.width = "25px";
      sectorEl.style.height = "25px";
      sectorEl.style.backgroundSize = "100%";

      // Change color to green if this sector is selected, otherwise use blue
      const markerColor = sector.id === selectedSectorId ? "%2322c55e" : "%232563eb";
      sectorEl.style.backgroundImage = `url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='${markerColor}' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z'/%3E%3Ccircle cx='12' cy='10' r='3'/%3E%3C/svg%3E")`;

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
      const markerColor = id === selectedSectorId ? "%2322c55e" : "%232563eb";
      el.style.backgroundImage = `url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='${markerColor}' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z'/%3E%3Ccircle cx='12' cy='10' r='3'/%3E%3C/svg%3E")`;
    });
  }, [selectedSectorId]);

  return (
    <div className="space-y-4">
      <div ref={mapContainer} className="bg-muted h-[400px] overflow-hidden rounded-md border" />
    </div>
  );
};

export default CragLocation;
