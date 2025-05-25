"use client";

import { ProfileAscentTypeChart } from "@/components/modules/profile/me-profile/ProfileAscentTypeChart";
import { ProfileAscentTypeTable } from "@/components/modules/profile/me-profile/ProfileAscentTypeTable";
import ProfileDetailsSkeleton from "@/components/modules/profile/me-profile/ProfileDetailsSkeleton";
import { ProfileGradeDistribution } from "@/components/modules/profile/me-profile/ProfileGradeDistribution";
import { ProfileRecentlyAscended } from "@/components/modules/profile/me-profile/ProfileRecentlyAscended";
import { ProfileStats } from "@/components/modules/profile/me-profile/ProfileStats";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  getApiUserRecentlyAscendedRoutesOptions,
  getApiUserUserByProfileUserIdOptions,
} from "@/lib/api/@tanstack/react-query.gen";
import useAuth from "@/lib/hooks/useAuth";
import { useQuery } from "@tanstack/react-query";
import { useState } from "react";

interface ClientProfileProps {
  userId?: string;
}

export default function ClientProfile({ userId: propUserId }: ClientProfileProps = {}) {
  const { user, isAuthenticated, isUserLoading } = useAuth();
  const [selectedRouteType, setSelectedRouteType] = useState<string | null>(null);

  // Use provided userId or fall back to current user's ID
  const userId = propUserId ?? user?.id ?? "";
  const isOwnProfile = !propUserId || propUserId === user?.id;

  const {
    data: profile,
    isLoading: isProfileLoading,
    error: profileError,
  } = useQuery({
    ...getApiUserUserByProfileUserIdOptions({ path: { profileUserId: userId } }),
    enabled: !!userId && (isOwnProfile ? isAuthenticated : true),
  });

  const {
    data: recentAscents,
    isLoading: isRecentLoading,
    error: recentError,
  } = useQuery({
    ...getApiUserRecentlyAscendedRoutesOptions(),
    enabled: isAuthenticated && isOwnProfile, // Only load recent ascents for own profile
  });

  const handleSelectRouteType = (routeType: string | null) => {
    if (routeType === selectedRouteType) {
      setSelectedRouteType(null);
    } else {
      setSelectedRouteType(routeType);
    }
  };

  if (isUserLoading || isProfileLoading || isRecentLoading || !profile) {
    return <ProfileDetailsSkeleton />;
  }

  if (profileError || recentError) {
    return <div className="text-destructive p-4">Error loading profile.</div>;
  }

  return (
    <div className="space-y-8 p-4">
      <ProfileStats profile={profile} />
      {isOwnProfile && recentAscents && <ProfileRecentlyAscended routes={recentAscents} />}

      {profile.routeTypeAscentCount && profile.routeTypeAscentCount.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Ascents by Route Type</CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <ProfileAscentTypeTable
              data={profile.routeTypeAscentCount}
              selectedRouteType={selectedRouteType}
              onSelectRouteType={handleSelectRouteType}
            />
            <ProfileAscentTypeChart data={profile.routeTypeAscentCount} onSelectRouteType={handleSelectRouteType} />
          </CardContent>
        </Card>
      )}

      {profile.climbingGradeAscentCount && profile.climbingGradeAscentCount.length > 0 && (
        <ProfileGradeDistribution data={profile.climbingGradeAscentCount} filterRouteType={selectedRouteType} />
      )}
    </div>
  );
}
