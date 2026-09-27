import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TodoData, TodoStore } from '../model/TodoModel';

const DOMAIN = 0x0000;
const TAG = 'AddTodo';

@Entry
@Component
struct AddTodo {
  @State inputText: string = '';

  private saveTodo() {
    const text: string = this.inputText.trim();
    if (text.length === 0) {
      return;
    }
    const context: Context = getContext(this);
    TodoStore.loadTodos(context).then((todos: TodoData[]) => {
      const next = [new TodoData(Date.now(), text, false)].concat(todos);
      return TodoStore.saveTodos(context, next).then(() => {
        return TodoStore.refreshAllCards(context, next);
      });
    }).then(() => {
      router.back();
    }).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'saveTodo error: %{public}s', JSON.stringify(error));
    });
  }

  build() {
    Column() {
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#666666')
          .padding({ top: 8, bottom: 8, right: 12 })
          .onClick(() => {
            router.back();
          })
        Text('新建待办')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('取消')
          .fontSize(16)
          .fontColor(Color.Transparent)
          .padding({ left: 12 })
      }
      .width('100%')

      TextInput({ text: this.inputText, placeholder: '输入待办内容' })
        .height(52)
        .backgroundColor('#FFFFFF')
        .borderRadius(14)
        .margin({ top: 24 })
        .defaultFocus(true)
        .onChange((value: string) => {
          this.inputText = value;
        })
        .onSubmit(() => {
          this.saveTodo();
        })

      Button('保存')
        .width('100%')
        .height(48)
        .borderRadius(24)
        .backgroundColor('#007DFF')
        .margin({ top: 24 })
        .enabled(this.inputText.trim().length > 0)
        .opacity(this.inputText.trim().length > 0 ? 1 : 0.5)
        .onClick(() => {
          this.saveTodo();
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F5F6FA')
    .alignItems(HorizontalAlign.Center)
  }
}
