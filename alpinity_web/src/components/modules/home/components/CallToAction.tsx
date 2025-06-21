import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import Link from "next/link";

export const CallToAction = () => {
  return (
    <div className="py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <Card>
          <div className="grid gap-6 md:grid-cols-2">
            <CardHeader className="pb-0 md:pb-6">
              <CardTitle className="text-3xl font-bold tracking-tight">Ready to send?</CardTitle>
              <CardDescription className="mt-4 text-lg">
                Download Alpinity today and unlock the most advanced digital climbing guidebook.
              </CardDescription>
            </CardHeader>
            <CardContent className="flex items-center justify-center p-6">
              <div className="w-full max-w-md space-y-4">
                <Button asChild size="lg" className="w-full">
                  <Link href="/register">Sign Up for Free</Link>
                </Button>
              </div>
            </CardContent>
          </div>
          <CardFooter className="text-muted-foreground border-t pt-6 text-sm">
            No credit card required. Start planning your next adventure today.
          </CardFooter>
        </Card>
      </div>
    </div>
  );
};
