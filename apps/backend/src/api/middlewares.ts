import { defineMiddlewares } from "@medusajs/framework/http"

const UPLOAD_SIZE_LIMIT = "10mb"

export default defineMiddlewares({
  routes: [
    {
      matcher: "/admin/uploads",
      method: ["POST"],
      bodyParser: {
        sizeLimit: UPLOAD_SIZE_LIMIT,
      },
    },
  ],
})
