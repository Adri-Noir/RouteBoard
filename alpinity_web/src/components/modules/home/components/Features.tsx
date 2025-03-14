import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Compass, MapPin, Mountain, Users } from "lucide-react";

export const Features = () => {
  const features = [
    {
      name: "Discover Routes",
      description: "Find thousands of curated routes for hiking, climbing, and outdoor activities.",
      icon: MapPin,
    },
    {
      name: "Detailed Information",
      description: "Get comprehensive details including difficulty, elevation, distance, and estimated time.",
      icon: Mountain,
    },
    {
      name: "Navigation",
      description: "Access offline maps and GPS tracking to navigate safely on your adventures.",
      icon: Compass,
    },
    {
      name: "Community",
      description: "Connect with fellow outdoor enthusiasts, share experiences, and join group activities.",
      icon: Users,
    },
  ];

  return (
    <div className="bg-white py-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mb-16 text-center">
          <h2 className="text-primary text-base font-semibold tracking-wide uppercase">Features</h2>
          <p className="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            Everything you need for your outdoor adventures
          </p>
          <p className="text-muted-foreground mx-auto mt-4 max-w-2xl text-xl">
            Our platform provides comprehensive tools and resources to plan, navigate, and share your outdoor
            experiences.
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
                <CardDescription className="text-base">{feature.description}</CardDescription>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
};
