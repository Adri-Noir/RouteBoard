"use client";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import Image from "next/image";
import { useState } from "react";

export const Hero = () => {
  const [searchQuery, setSearchQuery] = useState("");

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    console.log("Searching for:", searchQuery);
    // Implement search functionality here
  };

  return (
    <div className="relative h-[600px] w-full">
      {/* Hero Image */}
      <div className="absolute inset-0 z-0">
        <Image src="/images/hero_image.jpg" alt="Mountain landscape" fill priority className="object-cover" />
        <div className="absolute inset-0 bg-black/70" /> {/* Overlay for better text visibility */}
      </div>

      {/* Content */}
      <div className="relative z-10 flex h-full flex-col items-center justify-center px-4 text-center sm:px-6 lg:px-8">
        <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl md:text-6xl">
          Discover Your Next Adventure
        </h1>
        <p className="mx-auto mt-6 max-w-lg text-xl text-white">
          Find the perfect routes for hiking, climbing, and outdoor activities
        </p>

        {/* Search Bar */}
        <div className="mt-10 w-full max-w-lg">
          <form onSubmit={handleSearch} className="flex w-full flex-col items-center gap-2 sm:flex-row">
            <Input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search for crags, sectors, router or users..."
              className="rounded-md bg-white/95 px-4 py-6"
            />
            <Button type="submit" className="px-6 py-6">
              Search
            </Button>
          </form>
        </div>
      </div>
    </div>
  );
};
