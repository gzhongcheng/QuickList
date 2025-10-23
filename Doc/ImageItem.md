# ImageItem

Pure image display Item with customizable image aspect ratio, content margins, corner radius, etc., supports network image loading, can set whether to auto-adjust height. Uses image compression caching strategy to solve large image lag issues and improve scrolling smoothness.

![](./ImageRow.gif)

## Properties

> **aspectRatio**: Image estimated aspect ratio
> **autoSize**: Whether to auto-adjust size, when set to true, will update size based on actual image aspect ratio after image loads
>
> **imageUrl**: Network image address string
>
> **image**: Local UIImage
>
> **loadingIndicatorType**: Image loading style, `IndicatorType` type, specifically:
> ```
> .none Default no indicator
> .activity Use system indicator
> .image(imageData: Data) Use an image as indicator, supports gif
> .custom(indicator: Indicator) Use custom indicator, must follow Indicator protocol
> ```
>
> **placeholderImage**: Placeholder image while loading
>
> **loadFaildImage**: Failed loading image
>
> **contentMode**: Image fill mode
>
> **corners**: Array of image corner radius, `[CornerType]` type, if all four corners need rounding, can use `CornerType.all(10)`

## Usage Example
```
Section("Auto size three column images") { section in
    section.column = 3
    section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    section.lineSpace = 5
    section.itemSpace = 5
}
    <<< ImageItem() { row in
        row.imageUrl = "xxx"                                //url
        row.corners = [.leftTop(10),.rightBottom(15)] 		// Left top, right bottom corners
        row.autoSize = true									// Auto adjust size
        row.aspectRatio = CGSize(width: 1, height: 1) 		// Preset ratio
        row.loadFaildImage = UIImage(named: "load_faild")   // Failed loading image
    }
```
