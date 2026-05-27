import { StarIcon } from "@/icons"
import { themeIconColors } from "@/lib/theme-colors"

export const StarRating = ({
  rate,
  starSize = 20,
  disabled,
  "data-testid": dataTestId,
}: {
  rate: number
  starSize?: number
  disabled?: boolean
  "data-testid"?: string
}) => {
  return (
    <div className="flex" data-testid={dataTestId ?? 'star-rating'}>
      {[...Array(5)].map((_, i) => {
        const starColor =
          i < Math.floor(rate)
            ? disabled
              ? themeIconColors.contentDisabled
              : themeIconColors.contentPrimary
            : themeIconColors.actionOnPrimary
        return <StarIcon size={starSize} key={i} color={starColor} />
      })}
    </div>
  )
}
