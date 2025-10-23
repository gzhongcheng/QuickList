## Section Usage

Section serves as a collection container for Items, implementing Collection-related collection protocols. It supports accessing Item elements through subscripts and performing operations on Items through append, insert, replace, and remove methods.

#### Common Properties

> **isFormHeader**: Whether to serve as the floating header for the entire Form, only effective for the first section
> **suspensionDecoration**: Decoration view when the entire section is floating. This decoration view's display area covers the entire section, including header and footer areas. It only displays when floating and disappears when floating ends
>
> **tag**: Unique identifier for marking Section. Tags for sections in the same List must be different (otherwise it may cause some methods to get incorrect sections)
> **form**: The Form where the Section belongs
> **index**: Get the index position of the section in the form
> **items**: Array of all stored Items

#### Layout Related

> **column**: Number of columns (default 1 column)
> **lineSpace**: Line spacing (default 0)
> **itemSpace**: Column spacing (default 0)
> **contentInset**: Content margins
> **layout**: Custom layout object within the section, with higher priority than the form's layout

#### UI Related
> **header**: Section header
> **footer**: Section footer
> **decoration**: Section decoration view. The decoration view's display area is below the header and above the footer, serving as background decoration for the item group

#### Common Methods
> **estimateItemSize(with weight:)**: Get estimated size (square size calculated based on specified column count and spacing). Custom Items can use this method to get size for special requirements (usually not needed)
> **setTitleHeader(_ title:)**: Set system style header
> **setTitleFooter(_ title:)**: Set system style footer
> **hideAllItems(withOut:, withAnimation:)**: Hide all items except withOut (for collapse/expand)
> **showAllItems(withAnimation:)**: Show all items (for collapse/expand)
> **reload()**: Reload all Items
> **updateLayout(animation:)**: Only refresh interface layout

## Usage Example
```
Section(header: "Auto wrap", footer: nil) { section in
    /// Spacing settings
    section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    section.lineSpace = 10
    section.itemSpace = 10

    /// Column count settings
    section.column = 3

    // Custom header or footer
    /// Can be custom UICollectionReusableView type
    section.footer = SectionHeaderFooterView<UICollectionReusableView> { view,section in
        
    }
    /// Height calculation method (if this height property is not set, it will use the actual height of auto layout, constraints need to be set properly, recommend setting fixed height directly for fixed height header/footer)
    //section.footer?.height = { section, estimateItemSize, scrollDirection in
    //    return 40
    //}

    // Custom decoration view
    section.decoration = SectionDecorationView<UICollectionReusableView> { view in
        let imageView = UIImageView(image: UIImage(named: "E-1251692-C01A20FE"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    /// Set layout
//    section.layout = QuickYogaLayout(alignment: .flexStart, lineAlignment: .flexStart)
//    section.layout = QuickListFlowLayout()
    section.layout = RowEqualHeightLayout()
    /// Entire section floating
    section.isFormHeader = true
}
```