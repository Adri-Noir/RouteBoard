import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Compass, MapPin, Mountain, Users } from "lucide-react";

export const Overview = () => {
  const features = [
    {
      title: "AR Route Recognition",
      description: "Identify climbing lines in real-time with your phone’s camera.",
      icon: Compass,
    },
    {
      title: "Offline Guidebook",
      description: "Download crags & routes to stay informed when the signal drops.",
      icon: MapPin,
    },
    {
      title: "In-depth Beta",
      description: "Grades, length, type and local insights always at your fingertips.",
      icon: Mountain,
    },
    {
      title: "Progress Tracking",
      description: "Log ascents, analyse stats and share your climbing achievements.",
      icon: Users,
    },
  ];

  return (
    <section className="bg-muted/50 py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mb-16 text-center">
          <h2 className="text-primary text-base font-semibold tracking-wide uppercase">Why Alpinity</h2>
          <p className="mt-2 text-3xl font-bold tracking-tight sm:text-4xl">Your ultimate climbing companion</p>
          <p className="text-muted-foreground mx-auto mt-4 max-w-3xl text-xl">
            Plan, send and document your climbs with features crafted for the modern climber.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {features.map((feature) => (
            <Card key={feature.title} className="shadow-sm transition-shadow hover:shadow-md">
              <CardHeader className="flex flex-col items-center gap-4 pb-3 text-center">
                <div className="bg-primary text-primary-foreground flex size-12 items-center justify-center rounded-md">
                  <feature.icon className="size-6" />
                </div>
                <CardTitle className="text-lg leading-tight">{feature.title}</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription className="text-muted-foreground text-sm">{feature.description}</CardDescription>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
};
