"use client";

import { PointDto } from "@/lib/api/types.gen";

interface CragLocationProps {
  location: PointDto;
}

const CragLocation = ({ location }: CragLocationProps) => {
  return (
    <div>
      <div>
        <span>Latitude:</span>
        <span>{location.latitude}</span>
      </div>
    </div>
  );
};

export default CragLocation;
