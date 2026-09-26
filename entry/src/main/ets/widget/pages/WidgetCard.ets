let storage = new LocalStorage();

@Entry(storage)
@Component
struct WidgetCard {
  @LocalStorageProp('cardTitle') cardTitle: string = 'Hello World';
  @LocalStorageProp('cardHint') cardHint: string = '点击打开元服务';

  build() {
    Column() {
      Image($r('app.media.startIcon'))
        .width(48)
        .height(48)
        .borderRadius(12)
      Text(this.cardTitle)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .margin({ top: 10 })
      Text(this.cardHint)
        .fontSize(12)
        .fontColor(Color.Grey)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: {
          message: 'fromCard'
        }
      });
    })
  }
}
