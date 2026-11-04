# 城市插畫來源

使用內建 imagegen 工具產生，保留透明 PNG 原檔。沒有使用 CLI / API fallback。圖像是視覺插畫，地標比例並非測繪資料。

專案素材：

- `WorldTime/Assets.xcassets/London.imageset/London.png`
- `WorldTime/Assets.xcassets/Taipei.imageset/Taipei.png`
- `WorldTime/Assets.xcassets/NewYork.imageset/NewYork.png`

六個時段由 SwiftUI 的天空、日月與色彩疊合呈現，不是十八張不同的點陣背景。AppIcon 為程式繪製的簡單圖形。

## London — final prompt

Use case: stylized-concept. Create a premium painterly editorial city landscape cutout asset for a calm iPhone world clock app, portrait 1024x1536. Subject: LONDON viewed across the River Thames, recognizable Elizabeth Tower / Houses of Parliament with Westminster Bridge, dignified muted slate blue stone buildings and a soft warm hint of a few amber windows, layered atmospheric depth, delicate paper grain, refined cinematic hand-painted illustration, believable architecture. Composition: skyline and river occupy ONLY bottom 55 percent, horizon near 63% of full image; entire upper 45% must be genuinely transparent alpha, NOT white, black or checkerboard. Cutout transparent sky above architectural silhouette, river foreground runs fully to bottom and both edges. Buildings in soft neutral daytime illumination so the app can cast its own colored light. No sun, no moon, no stars, no clouds; no text, borders, frame, logos, UI or people. Elegant cool blue and desaturated teal tones, not cartoon or isometric. Full bleed water foreground with small rippled reflections, tower readable in lower half but no tall landmark above 40 percent image height. Output an actual PNG with transparency.

## Taipei — final prompt

Use case: stylized-concept. Create a premium painterly editorial city landscape cutout asset for a calm iPhone world clock app, portrait 1024x1536. Subject: TAIPEI city viewed from a low hillside with graceful Taipei 101 clearly recognizable, layered Xinyi district city buildings, distant soft mountain ridgeline, small park greenery and rooftops in the foreground. Refined cinematic hand-painted illustration, subtle paper grain and atmospheric depth, consistent with elegant travel magazine art. Composition: city and mountains occupy ONLY bottom 55 percent, skyline around 65% of full image, Taipei 101 pinnacle around 43%; entire upper 40% genuinely transparent alpha, NOT a white, black or checkerboard backdrop. Cutout transparent sky above architectural silhouette. City foreground runs full bleed to bottom and both edges. Soft neutral daytime illumination, cool blue slate and desaturated jade tones, warm hint of a few amber windows so the app can cast its own colored lighting. No sky, sun, moon, clouds, stars, people, text, borders, frame, logos or UI. Not cartoon, not isometric. Output PNG with actual transparency.

## New York — final prompt

Use case: stylized-concept. Create a premium painterly editorial city landscape cutout asset for a calm iPhone world clock app, portrait 1024x1536. Subject: NEW YORK CITY iconic lower Manhattan skyline from across the East River, One World Trade Center recognizable, layered elegant skyscrapers, Brooklyn Bridge gracefully crossing the lower foreground and river water reflecting the city. Refined cinematic hand-painted illustration, subtle paper grain and atmospheric depth, elegant travel magazine art. Composition: skyline and river occupy ONLY bottom 55 percent, tallest pinnacle about 43% of full image height; entire upper 40% genuinely transparent alpha, NOT white, black or checkerboard. Transparent sky above architectural silhouette. River fills foreground full bleed to bottom and both edges. Soft neutral daytime illumination, muted cool slate blue and desaturated teal, small warm amber window hints so app can cast its own colored light. No sun, moon, clouds, stars, text, logos, borders, frame, UI or people. Not cartoon or isometric. Actual PNG with transparency.

## 精選城市補充插畫

30 座精選城市中，除原有的 London、Taipei、New York 外，另有 27 張獨立透明 PNG，位於 `WorldTime/Assets.xcassets/City-<城市 id>.imageset/`。各圖以內建 imagegen 分別產生，並以 London 原圖為風格參考；城市地標會藝術化拼合，並非街景實拍。圖檔使用城市 id 命名，可直接對照 `CityCatalog`。

共通提示詞：Use case: stylized-concept. Create a transparent portrait landscape layer for a world-clock app depicting the named city with its recognizable local architecture and natural setting. Use the original London image as a style reference: refined painterly detail, muted slate blue, subtle warm lights, watercolor and paper texture, and a lower-half city composition. Leave the upper half transparent for the app's dynamic sky. No sun, moon, people, text, labels, borders, or UI. Make a separate image for each city.

城市：Tokyo、Seoul、Hong Kong、Singapore、Bangkok、Shanghai、Dubai、New Delhi、Paris、Berlin、Rome、Istanbul、Los Angeles、Chicago、Vancouver、Toronto、São Paulo、Sydney、Auckland、Honolulu、Cairo、Cape Town、Jakarta、Madrid、Amsterdam、Moscow、Mexico City。各圖提示中另有對應城市地標，例如 Tokyo Tower、Eiffel Tower、Sydney Opera House、Burj Khalifa 和 Mexico City 的 Palacio de Bellas Artes。
