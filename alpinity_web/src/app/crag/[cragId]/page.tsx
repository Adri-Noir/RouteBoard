import CragDetails from "@/components/modules/crag/CragDetails";
import CragDetailsSkeleton from "@/components/modules/crag/CragDetailsSkeleton";
import { Suspense } from "react";

interface CragPageProps {
  params: Promise<{
    cragId: string;
  }>;
}

const CragPage = async ({ params }: CragPageProps) => {
  // Await the params to prevent the "params should be awaited" error
  const { cragId } = await params;

  return (
    <div className="container mx-auto py-8">
      <Suspense fallback={<CragDetailsSkeleton />}>
        <CragDetails cragId={cragId} />
      </Suspense>
    </div>
  );
};

export default CragPage;
