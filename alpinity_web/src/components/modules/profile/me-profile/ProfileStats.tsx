"use client";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card, CardContent, CardDescription, CardTitle } from "@/components/ui/card";
import { UserProfileDto } from "@/lib/api/types.gen";

interface ProfileStatsProps {
  profile: UserProfileDto;
}

export function ProfileStats({ profile }: ProfileStatsProps) {
  const totalAscents =
    profile.routeTypeAscentCount?.reduce(
      (sum, item) => sum + (item.ascentCount?.reduce((s2, ac) => s2 + (ac.count ?? 0), 0) ?? 0),
      0,
    ) ?? 0;

  return (
    <Card>
      <CardContent className="p-6">
        <div className="flex flex-col items-center gap-6 lg:flex-row lg:justify-between">
          {/* User Info Section */}
          <div className="flex items-center space-x-4">
            <Avatar className="h-16 w-16">
              {profile.profilePhoto?.url ? (
                <AvatarImage src={profile.profilePhoto.url} alt={profile.username ?? ""} className="object-cover" />
              ) : (
                <AvatarFallback className="text-lg">{profile.username?.[0] ?? "?"}</AvatarFallback>
              )}
            </Avatar>
            <div>
              <CardTitle className="text-2xl">{profile.username}</CardTitle>
              {profile.firstName || profile.lastName ? (
                <CardDescription className="text-base">
                  {profile.firstName} {profile.lastName}
                </CardDescription>
              ) : null}
            </div>
          </div>

          {/* Stats Section */}
          <div className="grid grid-cols-3 gap-8">
            <div className="text-center">
              <p className="text-2xl font-bold">{profile.cragsVisited ?? 0}</p>
              <p className="text-muted-foreground text-sm">Crags Visited</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold">{totalAscents}</p>
              <p className="text-muted-foreground text-sm">Total Ascents</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold">{profile.photos?.length ?? 0}</p>
              <p className="text-muted-foreground text-sm">Photos</p>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
