import { Alert, Center, Loader, Text } from "@mantine/core";
import type { ReactNode } from "react";
import { errorMessage } from "../api/client";

export function QueryState({
  loading,
  error,
  empty,
  emptyLabel = "Nothing to show.",
  children,
}: {
  loading: boolean;
  error: unknown;
  empty?: boolean;
  emptyLabel?: string;
  children: ReactNode;
}) {
  if (loading) {
    return (
      <Center py="xl">
        <Loader />
      </Center>
    );
  }

  if (error) {
    return (
      <Alert color="red" title="Could not load data">
        {errorMessage(error)}
      </Alert>
    );
  }

  if (empty) return <Text c="dimmed">{emptyLabel}</Text>;

  return children;
}
