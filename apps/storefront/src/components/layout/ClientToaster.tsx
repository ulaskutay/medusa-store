"use client"

import dynamic from "next/dynamic"

const Toaster = dynamic(
  () => import("@medusajs/ui").then((mod) => mod.Toaster),
  { ssr: false }
)

export function ClientToaster() {
  return <Toaster position="top-right" />
}
