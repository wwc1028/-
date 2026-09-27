import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@kit.AbilityKit';
import { TodoData, TodoStore } from '../model/TodoModel';

const DOMAIN = 0x0000;
const TAG = 'TodoIndex';

@Entry
@Component
struct Index {
  @State todoList: TodoData[] = [];
  @State inputText: string = '';

  aboutToAppear() {
    this.loadTodos();
  }

  onPageShow() {
    this.loadTodos();
  }

  private loadTodos() {
    TodoStore.loadTodos(getContext(this)).then((todos: TodoData[]) => {
      this.todoList = todos;
    }).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'loadTodos error: %{public}s', JSON.stringify(error));
    });
  }

  private persistAndRefreshCards() {
    const context: Context = getContext(this);
    TodoStore.saveTodos(context, this.todoList).then(() => {
      return TodoStore.refreshAllCards(context, this.todoList);
    }).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'persist error: %{public}s', JSON.stringify(error));
    });
  }

  private addTodo() {
    const text: string = this.inputText.trim();
    if (text.length === 0) {
      return;
    }
    const todo = new TodoData(Date.now(), text, false);
    this.todoList = [todo].concat(this.todoList);
    this.inputText = '';
    this.persistAndRefreshCards();
  }

  private toggleTodo(id: number) {
    this.todoList = TodoStore.toggleDone(this.todoList, id);
    this.persistAndRefreshCards();
  }

  private removeTodo(id: number) {
    const next: TodoData[] = [];
    for (const item of this.todoList) {
      if (item.id !== id) {
        next.push(item);
      }
    }
    this.todoList = next;
    this.persistAndRefreshCards();
  }

  build() {
    Column() {
      Row() {
        Text('待办事项')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
        Text(`${this.todoList.length} 项`)
          .fontSize(14)
          .fontColor(Color.Grey)
      }
      .width('100%')

      Row({ space: 8 }) {
        TextInput({ text: this.inputText, placeholder: '输入新待办' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F1F3F5')
          .borderRadius(22)
          .onChange((value: string) => {
            this.inputText = value;
          })
          .onSubmit(() => {
            this.addTodo();
          })
        Button('添加')
          .height(44)
          .borderRadius(22)
          .backgroundColor('#007DFF')
          .onClick(() => {
            this.addTodo();
          })
      }
      .width('100%')
      .margin({ top: 16 })

      if (this.todoList.length === 0) {
        Column() {
          Text('暂无待办事项')
            .fontSize(16)
            .fontColor(Color.Grey)
            .margin({ bottom: 8 })
          Text('在上方输入框添加第一条待办吧')
            .fontSize(13)
            .fontColor('#BBBBBB')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.todoList, (item: TodoData) => {
            ListItem() {
              Row({ space: 10 }) {
                Checkbox()
                  .select(item.done)
                  .width(22)
                  .height(22)
                  .selectedColor('#007DFF')
                  .onChange((value: boolean) => {
                    if (value !== item.done) {
                      this.toggleTodo(item.id);
                    }
                  })
                Text(item.text)
                  .layoutWeight(1)
                  .fontSize(16)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .decoration({ type: item.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                  .fontColor(item.done ? Color.Grey : '#333333')
                Text('✕')
                  .fontSize(16)
                  .fontColor('#CCCCCC')
                  .padding({ left: 8, right: 4, top: 4, bottom: 4 })
                  .onClick(() => {
                    this.removeTodo(item.id);
                  })
              }
              .width('100%')
              .padding(14)
              .borderRadius(14)
              .backgroundColor('#FFFFFF')
            }
          }, (item: TodoData): string => item.id.toString())
        }
        .layoutWeight(1)
        .width('100%')
        .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F5F6FA')
  }
}
