"use client";

import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  deleteApiCragByIdMutation,
  deleteApiRouteByIdMutation,
  deleteApiSectorByIdMutation,
  getApiCragByIdOptions,
  getApiMapWeatherByCragIdOptions,
} from "@/lib/api/@tanstack/react-query.gen";
import { CragDetailedDto } from "@/lib/api/types.gen";
import useAuth from "@/lib/hooks/useAuth";
import { cn } from "@/lib/utils";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { AlertCircle, Edit, Loader2, MoreHorizontal, Plus, Trash2 } from "lucide-react";
import { useRouter, useSearchParams } from "next/navigation";
import { useCallback, useMemo, useState } from "react";
import CreateRouteForm from "../route/create-route/CreateRouteForm";
import SectorDetails from "../sector/SectorDetails";
import SectorSelector from "../sector/SectorSelector";
import CreateSectorForm from "../sector/create-sector/CreateSectorForm";
import CragAllRoutes from "./CragAllRoutes";
import CragDetailsSkeleton from "./CragDetailsSkeleton";
import CragHeader from "./CragHeader";
import CragLocation from "./CragLocation";
import CragPhotos from "./CragPhotos";
import CragWeather from "./CragWeather";
import CreateCragForm from "./create-crag/CreateCragForm";

interface CragDetailsProps {
  cragId: string;
  initialData?: CragDetailedDto | null;
}

const CragDetails = ({ cragId, initialData }: CragDetailsProps) => {
  const { isAuthenticated } = useAuth();
  const searchParams = useSearchParams();
  const router = useRouter();
  const queryClient = useQueryClient();

  const initialSectorId = searchParams.get("sectorId") ?? undefined;
  const [selectedSectorId, setSelectedSectorId] = useState<string | undefined>(initialSectorId);
  const [isEditCragModalOpen, setIsEditCragModalOpen] = useState(false);
  const [isCreateSectorModalOpen, setIsCreateSectorModalOpen] = useState(false);
  const [isDeleteCragModalOpen, setIsDeleteCragModalOpen] = useState(false);
  const [isEditSectorModalOpen, setIsEditSectorModalOpen] = useState(false);
  const [isCreateRouteModalOpen, setIsCreateRouteModalOpen] = useState(false);
  const [isDeleteSectorModalOpen, setIsDeleteSectorModalOpen] = useState(false);
  const [isEditRouteModalOpen, setIsEditRouteModalOpen] = useState(false);
  const [isDeleteRouteModalOpen, setIsDeleteRouteModalOpen] = useState(false);
  const [selectedRouteForEdit, setSelectedRouteForEdit] = useState<string | null>(null);

  const {
    data: crag,
    error: cragError,
    isLoading: cragIsLoading,
  } = useQuery({
    ...getApiCragByIdOptions({
      path: {
        id: cragId,
      },
    }),
    initialData: initialData ?? undefined,
    enabled: isAuthenticated,
  });

  const { data: weatherData } = useQuery({
    ...getApiMapWeatherByCragIdOptions({
      path: {
        cragId,
      },
    }),
  });

  const { mutate: deleteCrag, isPending: isDeleteLoading } = useMutation({
    ...deleteApiCragByIdMutation(),
    onSuccess: () => {
      queryClient.invalidateQueries();
      // Navigate back to home or crags list after successful deletion
      router.push("/");
    },
  });

  const { mutate: deleteSector, isPending: isDeleteSectorLoading } = useMutation({
    ...deleteApiSectorByIdMutation(),
    onSuccess: () => {
      queryClient.invalidateQueries();
      setIsDeleteSectorModalOpen(false);
      // Clear selected sector if it was deleted
      setSelectedSectorId(undefined);
      router.push(`/crag/${cragId}`, { scroll: false });
    },
  });

  const { mutate: deleteRoute, isPending: isDeleteRouteLoading } = useMutation({
    ...deleteApiRouteByIdMutation(),
    onSuccess: () => {
      queryClient.invalidateQueries();
      setIsDeleteRouteModalOpen(false);
      setSelectedRouteForEdit(null);
    },
  });

  const selectedSector = useMemo(() => {
    return crag?.sectors?.find((sector) => sector.id === selectedSectorId);
  }, [crag?.sectors, selectedSectorId]);

  const selectedRouteForEditData = useMemo(() => {
    if (!selectedRouteForEdit || !crag?.sectors) return null;

    for (const sector of crag.sectors) {
      const route = sector.routes?.find((r) => r.id === selectedRouteForEdit);
      if (route) {
        return {
          route,
          sector,
        };
      }
    }
    return null;
  }, [selectedRouteForEdit, crag?.sectors]);

  const handleSectorChange = useCallback(
    (sectorId: string) => {
      setSelectedSectorId(sectorId);
      const params = new URLSearchParams();
      params.set("sectorId", sectorId);
      router.push(`/crag/${cragId}?${params.toString()}`, { scroll: false });
    },
    [cragId, router],
  );

  const handleEditCrag = useCallback(() => {
    setIsEditCragModalOpen(true);
  }, []);

  const handleCreateSector = useCallback(() => {
    setIsCreateSectorModalOpen(true);
  }, []);

  const handleCragUpdateSuccess = useCallback(() => {
    setIsEditCragModalOpen(false);
    // The query will be invalidated automatically by the mutation
  }, []);

  const handleSectorCreateSuccess = useCallback(() => {
    setIsCreateSectorModalOpen(false);
    // The query will be invalidated automatically by the mutation
  }, []);

  const handleDeleteCrag = useCallback(() => {
    setIsDeleteCragModalOpen(true);
  }, []);

  const handleDeleteCragConfirm = useCallback(() => {
    deleteCrag({
      path: { id: cragId },
    });
    setIsDeleteCragModalOpen(false);
  }, [cragId, deleteCrag]);

  const handleEditSector = useCallback(() => {
    setIsEditSectorModalOpen(true);
  }, []);

  const handleCreateRoute = useCallback(() => {
    setIsCreateRouteModalOpen(true);
  }, []);

  const handleDeleteSector = useCallback(() => {
    setIsDeleteSectorModalOpen(true);
  }, []);

  const handleDeleteSectorConfirm = useCallback(() => {
    if (selectedSectorId) {
      deleteSector({
        path: { id: selectedSectorId },
      });
    }
  }, [selectedSectorId, deleteSector]);

  const handleSectorUpdateSuccess = useCallback(() => {
    setIsEditSectorModalOpen(false);
    // The query will be invalidated automatically by the mutation
  }, []);

  const handleRouteCreateSuccess = useCallback(() => {
    setIsCreateRouteModalOpen(false);
    // The query will be invalidated automatically by the mutation
  }, []);

  const handleEditRoute = useCallback((routeId: string) => {
    setSelectedRouteForEdit(routeId);
    setIsEditRouteModalOpen(true);
  }, []);

  const handleDeleteRoute = useCallback((routeId: string) => {
    setSelectedRouteForEdit(routeId);
    setIsDeleteRouteModalOpen(true);
  }, []);

  const handleDeleteRouteConfirm = useCallback(() => {
    if (selectedRouteForEdit) {
      deleteRoute({
        path: { id: selectedRouteForEdit },
      });
    }
  }, [selectedRouteForEdit, deleteRoute]);

  const handleRouteUpdateSuccess = useCallback(() => {
    setIsEditRouteModalOpen(false);
    setSelectedRouteForEdit(null);
    // The query will be invalidated automatically by the mutation
  }, []);

  const sectors = useMemo(
    () =>
      crag?.sectors
        ?.filter(
          (sector) =>
            sector.name &&
            sector.location &&
            typeof sector.location.latitude === "number" &&
            typeof sector.location.longitude === "number",
        )
        .map((sector) => ({
          latitude: sector.location!.latitude,
          longitude: sector.location!.longitude,
          id: sector.id,
          name: sector.name || undefined,
        })),
    [crag?.sectors],
  );

  const hasWeatherData = !!weatherData?.current || !!weatherData?.hourly || !!weatherData?.daily;

  const showNoData = !hasWeatherData && !crag?.location && crag?.photos?.length === 0 && crag?.sectors?.length === 0;

  if (cragError) {
    return (
      <Alert variant="destructive">
        <AlertCircle className="h-4 w-4" />
        <AlertTitle>Error</AlertTitle>
        <AlertDescription>Failed to load crag details. Please try again later.</AlertDescription>
      </Alert>
    );
  }

  if (cragIsLoading || !crag) {
    return <CragDetailsSkeleton />;
  }

  return (
    <div className="space-y-8 px-0 sm:px-6 lg:px-8">
      <CragHeader
        cragId={cragId}
        name={crag.name || "Unnamed Crag"}
        description={crag.description}
        locationName={crag.locationName}
        canModify={crag.canModify}
        onEditCrag={handleEditCrag}
        onCreateSector={handleCreateSector}
        onDeleteCrag={handleDeleteCrag}
      />

      {showNoData && (
        <section className="rounded-lg p-4 md:border">
          <h2 className="mb-4 text-2xl font-semibold">No data</h2>
          <p className="text-muted-foreground">No data available for this crag.</p>
        </section>
      )}

      {cragId && hasWeatherData && (
        <section className="rounded-lg p-4 md:border">
          <h2 className="mb-4 text-2xl font-semibold">Weather</h2>
          <CragWeather cragId={cragId} />
        </section>
      )}

      {crag.location && (
        <section className="rounded-lg p-4 md:border">
          <h2 className="mb-4 text-2xl font-semibold">Location</h2>
          <CragLocation
            location={crag.location}
            sectors={sectors}
            onSectorClick={handleSectorChange}
            selectedSectorId={selectedSectorId}
          />
        </section>
      )}

      {crag.photos && crag.photos.length > 0 && (
        <section className="rounded-lg p-4 md:border">
          <h2 className="mb-4 text-2xl font-semibold">Photos</h2>
          <div className="relative flex justify-between px-12">
            <CragPhotos photos={crag.photos} />
          </div>
        </section>
      )}

      {crag.sectors && crag.sectors.length > 0 && (
        <section className="rounded-lg p-4 md:border">
          <h2 className="mb-4 text-2xl font-semibold">Sectors</h2>

          <div className={cn(selectedSectorId ? "space-y-0" : "space-y-8")}>
            {/* Sector Selection */}
            <div className="flex justify-between">
              <SectorSelector
                sectors={crag.sectors}
                currentSectorId={selectedSectorId}
                onSectorChange={(sectorId) => {
                  if (sectorId) {
                    handleSectorChange(sectorId);
                  } else {
                    setSelectedSectorId(undefined);
                    router.push(`/crag/${cragId}`, { scroll: false });
                  }
                }}
              />
              {crag.canModify && !!selectedSectorId && (
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="outline" size="icon">
                      <MoreHorizontal className="h-4 w-4" />
                      <span className="sr-only">Sector options</span>
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DropdownMenuItem onClick={handleEditSector}>
                      <Edit className="mr-2 h-4 w-4" />
                      Edit Sector
                    </DropdownMenuItem>
                    <DropdownMenuItem onClick={handleCreateRoute}>
                      <Plus className="mr-2 h-4 w-4" />
                      Add Route
                    </DropdownMenuItem>
                    <DropdownMenuItem onClick={handleDeleteSector} className="text-destructive">
                      <Trash2 className="mr-2 h-4 w-4" />
                      Delete Sector
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              )}
            </div>

            {/* Selected Sector Details or All Routes Table */}
            {selectedSectorId ? (
              <>
                {selectedSector ? (
                  <SectorDetails
                    sector={selectedSector}
                    canModify={crag.canModify}
                    onEditRoute={handleEditRoute}
                    onDeleteRoute={handleDeleteRoute}
                  />
                ) : null}
              </>
            ) : (
              <CragAllRoutes crag={crag} onEditRoute={handleEditRoute} onDeleteRoute={handleDeleteRoute} />
            )}
          </div>
        </section>
      )}

      {/* Edit Crag Modal */}
      <Dialog open={isEditCragModalOpen} onOpenChange={setIsEditCragModalOpen}>
        <DialogContent className="max-h-[90vh] max-w-4xl overflow-y-auto" aria-describedby="edit-crag-description">
          <DialogHeader>
            <DialogTitle>Edit Crag</DialogTitle>
          </DialogHeader>
          <CreateCragForm crag={crag} onSuccess={handleCragUpdateSuccess} />
        </DialogContent>
      </Dialog>

      {/* Create Sector Modal */}
      <Dialog open={isCreateSectorModalOpen} onOpenChange={setIsCreateSectorModalOpen}>
        <DialogContent className="max-h-[90vh] max-w-4xl overflow-y-auto" aria-describedby="create-sector-description">
          <DialogHeader>
            <DialogTitle>Create New Sector</DialogTitle>
          </DialogHeader>
          <CreateSectorForm
            cragId={cragId}
            cragLocation={
              crag.location ? { latitude: crag.location.latitude, longitude: crag.location.longitude } : undefined
            }
            onSuccess={handleSectorCreateSuccess}
          />
        </DialogContent>
      </Dialog>

      <Dialog open={isDeleteCragModalOpen} onOpenChange={setIsDeleteCragModalOpen}>
        <DialogContent className="max-h-[90vh] max-w-4xl overflow-y-auto" aria-describedby="delete-crag-description">
          <DialogHeader>
            <DialogTitle>Delete Crag</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <p className="text-muted-foreground text-sm">
              Are you sure you want to delete &quot;{crag.name}&quot;? This action cannot be undone and will permanently
              delete the crag and all its sectors and routes.
            </p>
            <div className="flex justify-end space-x-2">
              <Button variant="outline" onClick={() => setIsDeleteCragModalOpen(false)} disabled={isDeleteLoading}>
                Cancel
              </Button>
              <Button variant="destructive" onClick={handleDeleteCragConfirm} disabled={isDeleteLoading}>
                {isDeleteLoading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Deleting...
                  </>
                ) : (
                  "Delete Crag"
                )}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      <Dialog open={isEditSectorModalOpen} onOpenChange={setIsEditSectorModalOpen}>
        <DialogContent className="max-h-[90vh] max-w-4xl overflow-y-auto" aria-describedby="edit-sector-description">
          <DialogHeader>
            <DialogTitle>Edit Sector</DialogTitle>
          </DialogHeader>
          {selectedSector && (
            <CreateSectorForm
              sector={selectedSector}
              cragId={cragId}
              cragLocation={
                crag.location ? { latitude: crag.location.latitude, longitude: crag.location.longitude } : undefined
              }
              onSuccess={handleSectorUpdateSuccess}
            />
          )}
        </DialogContent>
      </Dialog>

      <Dialog open={isCreateRouteModalOpen} onOpenChange={setIsCreateRouteModalOpen}>
        <DialogContent className="max-h-[90vh] max-w-4xl overflow-y-auto" aria-describedby="create-route-description">
          <DialogHeader>
            <DialogTitle>Create New Route</DialogTitle>
          </DialogHeader>
          <CreateRouteForm sectorId={selectedSectorId} onSuccess={handleRouteCreateSuccess} />
        </DialogContent>
      </Dialog>

      <Dialog open={isDeleteSectorModalOpen} onOpenChange={setIsDeleteSectorModalOpen}>
        <DialogContent className="max-h-[90vh] max-w-4xl overflow-y-auto" aria-describedby="delete-sector-description">
          <DialogHeader>
            <DialogTitle>Delete Sector</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <p className="text-muted-foreground text-sm">
              Are you sure you want to delete this sector? This action cannot be undone and will permanently delete the
              sector and all its routes.
            </p>
            <div className="flex justify-end space-x-2">
              <Button
                variant="outline"
                onClick={() => setIsDeleteSectorModalOpen(false)}
                disabled={isDeleteSectorLoading}
              >
                Cancel
              </Button>
              <Button variant="destructive" onClick={handleDeleteSectorConfirm} disabled={isDeleteSectorLoading}>
                {isDeleteSectorLoading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Deleting...
                  </>
                ) : (
                  "Delete Sector"
                )}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      <Dialog open={isEditRouteModalOpen} onOpenChange={setIsEditRouteModalOpen}>
        <DialogContent className="max-h-[90vh] max-w-4xl overflow-y-auto" aria-describedby="edit-route-description">
          <DialogHeader>
            <DialogTitle>Edit Route</DialogTitle>
          </DialogHeader>
          {selectedRouteForEditData &&
            (() => {
              const { route, sector } = selectedRouteForEditData;

              return (
                <CreateRouteForm
                  route={{
                    ...route,
                    sectorId: sector.id,
                    sectorName: sector.name,
                    cragId: crag.id || "",
                    cragName: crag.name || null,
                    ascents: null,
                    canModify: crag.canModify,
                  }}
                  onSuccess={handleRouteUpdateSuccess}
                />
              );
            })()}
        </DialogContent>
      </Dialog>

      <Dialog open={isDeleteRouteModalOpen} onOpenChange={setIsDeleteRouteModalOpen}>
        <DialogContent className="max-h-[90vh] max-w-4xl overflow-y-auto" aria-describedby="delete-route-description">
          <DialogHeader>
            <DialogTitle>Delete Route</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <p className="text-muted-foreground text-sm">
              Are you sure you want to delete this route? This action cannot be undone and will permanently delete the
              route.
            </p>
            <div className="flex justify-end space-x-2">
              <Button
                variant="outline"
                onClick={() => setIsDeleteRouteModalOpen(false)}
                disabled={isDeleteRouteLoading}
              >
                Cancel
              </Button>
              <Button variant="destructive" onClick={handleDeleteRouteConfirm} disabled={isDeleteRouteLoading}>
                {isDeleteRouteLoading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Deleting...
                  </>
                ) : (
                  "Delete Route"
                )}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default CragDetails;
