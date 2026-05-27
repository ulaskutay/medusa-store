import type { MedusaContainer } from "@medusajs/framework/types"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"

const TURKEY_REGION_ID = "reg_01KSNV1JS7EXRCEGFED77DF1HE"
const TURKEY_STORE_LOCALE = "tr-TR"

/**
 * Türkiye mağaza ayarları: TRY para birimi, tr-TR içerik dili, varsayılan bölge.
 * Çalıştırma: cd apps/backend && npx medusa exec ./src/scripts/setup-try-currency.ts
 */
export default async function setupTryCurrency({
  container,
}: {
  container: MedusaContainer
}) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const regionService = container.resolve(Modules.REGION)
  const storeModuleService = container.resolve(Modules.STORE)

  const [region] = await regionService.listRegions({ id: TURKEY_REGION_ID })
  if (!region) {
    throw new Error(`Türkiye bölgesi bulunamadı: ${TURKEY_REGION_ID}`)
  }

  if (region.currency_code !== "try") {
    await regionService.updateRegions(TURKEY_REGION_ID, {
      currency_code: "try",
    })
    logger.info("Türkiye bölgesi para birimi TRY olarak güncellendi.")
  } else {
    logger.info("Türkiye bölgesi zaten TRY kullanıyor.")
  }

  const [store] = await storeModuleService.listStores(
    {},
    { relations: ["supported_currencies", "supported_locales"] }
  )
  if (!store) {
    throw new Error("Mağaza bulunamadı.")
  }

  const hasTry = store.supported_currencies?.some(
    (c) => c.currency_code === "try"
  )

  if (!hasTry) {
    await storeModuleService.updateStores(store.id, {
      supported_currencies: [
        ...(store.supported_currencies?.map((c) => ({
          currency_code: c.currency_code,
          is_default: c.is_default,
        })) ?? []),
        { currency_code: "try", is_default: false },
      ],
    })
    logger.info("Mağazaya TRY para birimi eklendi.")
  } else {
    logger.info("Mağaza zaten TRY destekliyor.")
  }

  const hasTrLocale = store.supported_locales?.some(
    (l) => l.locale_code === TURKEY_STORE_LOCALE
  )

  if (!hasTrLocale) {
    await storeModuleService.updateStores(store.id, {
      supported_locales: [
        ...(store.supported_locales?.map((l) => ({
          locale_code: l.locale_code,
        })) ?? []),
        { locale_code: TURKEY_STORE_LOCALE },
      ],
      default_region_id: TURKEY_REGION_ID,
    })
    logger.info(`Mağazaya ${TURKEY_STORE_LOCALE} dili eklendi; varsayılan bölge Türkiye yapıldı.`)
  } else {
    if (store.default_region_id !== TURKEY_REGION_ID) {
      await storeModuleService.updateStores(store.id, {
        default_region_id: TURKEY_REGION_ID,
      })
      logger.info("Mağaza varsayılan bölgesi Türkiye olarak güncellendi.")
    } else {
      logger.info(`Mağaza zaten ${TURKEY_STORE_LOCALE} dilini destekliyor.`)
    }
  }

  logger.info(
    "Sonraki adım: Admin → Ayarlar → Çeviriler veya ürün detayından Türkçe başlık/açıklama ekleyin; TRY fiyatları tanımlayın."
  )
}
