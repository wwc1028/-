let storage = new LocalStorage();

@Entry(storage)
@Component
struct WidgetCard {
  @LocalStorageProp('todoCount') todoCount: string = '0';
  @LocalStorageProp('hasTodo') hasTodo: string = '0';
  @LocalStorageProp('todo0Text') todo0Text: string = '';
  @LocalStorageProp('todo0Id') todo0Id: string = '0';
  @LocalStorageProp('todo0Done') todo0Done: string = '0';
  @LocalStorageProp('todo1Text') todo1Text: string = '';
  @LocalStorageProp('todo1Id') todo1Id: string = '0';
  @LocalStorageProp('todo1Done') todo1Done: string = '0';
  @LocalStorageProp('todo2Text') todo2Text: string = '';
  @LocalStorageProp('todo2Id') todo2Id: string = '0';
  @LocalStorageProp('todo2Done') todo2Done: string = '0';

  private toggleCard(todoId: string) {
    postCardAction(this, {
      action: 'message',
      params: {
        action: 'toggle',
        todoId: todoId
      }
    });
  }

  private openApp() {
    postCardAction(this, {
      action: 'router',
      abilityName: 'EntryAbility',
      params: {
        message: 'fromCard'
      }
    });
  }

  build() {
    Column() {
      Row() {
        Text('待办')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Text(this.todoCount + ' 项未完成')
          .fontSize(12)
          .fontColor(Color.Grey)
          .margin({ left: 6 })
          .layoutWeight(1)
        Text('添加 ›')
          .fontSize(12)
          .fontColor('#007DFF')
          .onClick(() => {
            this.openApp();
          })
      }
      .width('100%')

      if (this.hasTodo === '1') {
        Column({ space: 6 }) {
          if (this.todo0Text !== '') {
            Row({ space: 6 }) {
              Checkbox()
                .select(this.todo0Done === '1')
                .width(16)
                .height(16)
                .selectedColor('#007DFF')
              Text(this.todo0Text)
                .fontSize(13)
                .fontColor('#333333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }
            .width('100%')
            .onClick(() => {
              this.toggleCard(this.todo0Id);
            })
          }
          if (this.todo1Text !== '') {
            Row({ space: 6 }) {
              Checkbox()
                .select(this.todo1Done === '1')
                .width(16)
                .height(16)
                .selectedColor('#007DFF')
              Text(this.todo1Text)
                .fontSize(13)
                .fontColor('#333333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }
            .width('100%')
            .onClick(() => {
              this.toggleCard(this.todo1Id);
            })
          }
          if (this.todo2Text !== '') {
            Row({ space: 6 }) {
              Checkbox()
                .select(this.todo2Done === '1')
                .width(16)
                .height(16)
                .selectedColor('#007DFF')
              Text(this.todo2Text)
                .fontSize(13)
                .fontColor('#333333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }
            .width('100%')
            .onClick(() => {
              this.toggleCard(this.todo2Id);
            })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 10 })
      } else {
        Text('暂无待办，点击去添加')
          .fontSize(13)
          .fontColor(Color.Grey)
          .margin({ top: 16 })
          .onClick(() => {
            this.openApp();
          })
      }
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .alignItems(HorizontalAlign.Start)
  }
}
