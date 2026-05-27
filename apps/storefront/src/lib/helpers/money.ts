import { isEmpty } from "./isEmpty"
import { toHreflang } from "./hreflang"

type ConvertToLocaleParams = {
  amount: number
  currency_code: string
  minimumFractionDigits?: number
  maximumFractionDigits?: number
  /** Ülke kodu (ör. tr) veya BCP-47 locale (ör. tr-TR) */
  locale?: string
}

const currencyLocaleFallback: Record<string, string> = {
  try: "tr-TR",
  eur: "de-DE",
  gbp: "en-GB",
  usd: "en-US",
}

export const resolvePriceLocale = (
  currency_code: string,
  locale?: string
): string => {
  if (locale?.includes("-")) {
    return locale
  }
  if (locale) {
    return toHreflang(locale)
  }
  const code = currency_code?.toLowerCase()
  return currencyLocaleFallback[code] ?? "en-US"
}

export const convertToLocale = ({
  amount,
  currency_code,
  minimumFractionDigits,
  maximumFractionDigits,
  locale,
}: ConvertToLocaleParams) => {
  const intlLocale = resolvePriceLocale(currency_code, locale)

  return currency_code && !isEmpty(currency_code)
    ? new Intl.NumberFormat(intlLocale, {
        style: "currency",
        currency: currency_code,
        minimumFractionDigits,
        maximumFractionDigits,
      }).format(amount)
    : amount.toString()
}
