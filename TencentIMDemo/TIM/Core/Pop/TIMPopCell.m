//
//  TIMPopCell.m
//  TencentIMDemo
//
//  Created by Sauron on 2022/11/22.
//  Copyright © 2022 sauronpi. All rights reserved.
//

#import "TIMPopCell.h"
#import "TUIThemeManager.h"

@implementation TIMPopCellData
@end

@implementation TIMPopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor clearColor];

    _image = [[UIImageView alloc] init];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_image];

    _title = [[UILabel alloc] init];
    _title.font = [UIFont systemFontOfSize:15];
    _title.textColor = TUIDemoDynamicColor(@"pop_text_color", @"#FFFFFF");
    _title.numberOfLines = 0;
    [self addSubview:_title];

    [self setSeparatorInset:UIEdgeInsetsMake(0, TPopCell_Padding, 0, 0)];
}

- (void)layoutSubviews
{
    CGFloat headHeight = TPopCell_Height - 2 * TPopCell_Padding;
    self.image.frame = CGRectMake(TPopCell_Padding, TPopCell_Padding, headHeight, headHeight);
    self.image.center = CGPointMake(self.image.center.x, self.contentView.center.y);
    
    CGFloat titleWidth = self.frame.size.width - 2 * TPopCell_Padding - TPopCell_Margin - _image.frame.size.width;
    self.title.frame = CGRectMake(_image.frame.origin.x + _image.frame.size.width + TPopCell_Margin, TPopCell_Padding, titleWidth, self.contentView.bounds.size.height);
    self.title.center = CGPointMake(self.title.center.x, self.contentView.center.y);
}

- (void)setData:(TIMPopCellData *)data
{
    _image.image = data.image;
    _title.text = data.title;
}

+ (CGFloat)getHeight
{
    return TPopCell_Height;
}
@end
