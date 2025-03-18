"use client";

import Link from "next/link";

interface SectorHeaderProps {
  name: string;
  description?: string | null;
  cragName?: string | null;
  cragId?: string;
}

const SectorHeader = ({ name, description, cragName, cragId }: SectorHeaderProps) => {
  return (
    <header className="space-y-2">
      <div>
        {cragId && cragName && (
          <div className="text-muted-foreground mb-1 text-sm">
            <Link href={`/crag/${cragId}`} className="hover:underline">
              {cragName}
            </Link>
          </div>
        )}
        <h1 className="text-3xl font-bold tracking-tight sm:text-4xl">{name}</h1>
      </div>
      {description && <p className="text-muted-foreground text-lg">{description}</p>}
    </header>
  );
};

export default SectorHeader;
