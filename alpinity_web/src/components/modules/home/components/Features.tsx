import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Compass, MapPin, Mountain, Users } from "lucide-react";

export const Features = () => {
  const features = [
    {
      name: "AR Route Recognition",
      description: "Identify climbing routes in real-time through augmented reality.",
      icon: Compass,
    },
    {
      name: "Offline Mode",
      description: "Download crags & routes to keep guidance when the signal drops.",
      icon: MapPin,
    },
    {
      name: "Comprehensive Guide",
      description: "Access grades, length, style & local beta for 12k+ routes.",
      icon: Mountain,
    },
    {
      name: "Personal Progress",
      description: "Track ascents, stats and grade progression over time.",
      icon: Users,
    },
  ];

  return (
    <section className="py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mb-16 text-center">
          <h2 className="text-primary text-base font-semibold tracking-wide uppercase">Core Features</h2>
          <p className="mt-2 text-3xl font-bold tracking-tight sm:text-4xl">Designed for climbers, by climbers</p>
          <p className="text-muted-foreground mx-auto mt-4 max-w-2xl text-xl">
            Powerful utilities that make planning, sending and logging climbs effortless.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {features.map((feature) => (
            <Card key={feature.name} className="shadow-md transition-shadow hover:shadow-lg">
              <CardHeader className="pb-2">
                <div className="bg-primary text-primary-foreground mb-4 flex h-12 w-12 items-center justify-center rounded-md">
                  <feature.icon className="h-6 w-6" aria-hidden="true" />
                </div>
                <CardTitle className="text-lg">{feature.name}</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription className="text-foreground text-base leading-snug">
                  {feature.description}
                </CardDescription>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
};
