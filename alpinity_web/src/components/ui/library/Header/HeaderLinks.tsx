"use client";
import useAuth from "@/lib/hooks/useAuth";
import Link from "next/link";

const HeaderLinks = () => {
  const { isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return null;
  }

  return (
    <div className="flex items-center gap-10">
      <Link href="/explore">Explore</Link>
      <Link href="/map">Map</Link>
    </div>
  );
};

export default HeaderLinks;
