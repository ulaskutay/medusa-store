"use client"

import type { ReactNode } from "react"

import { HtmlLangSetter } from "@/components/atoms/HtmlLangSetter/HtmlLangSetter"
import { Providers } from "@/app/providers"
import { ClientToaster } from "@/components/layout/ClientToaster"
import type { Cart } from "@/types/cart"

type RootShellProps = {
  children: ReactNode
  cart: Cart | null
}

export function RootShell({ children, cart }: RootShellProps) {
  return (
    <>
      <HtmlLangSetter />
      <Providers cart={cart}>{children}</Providers>
      <ClientToaster />
    </>
  )
}
