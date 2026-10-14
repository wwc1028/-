import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@kit.AbilityKit';
import { TodoData, TodoStore } from '../model/TodoModel';

const DOMAIN = 0x0000;
const TAG = 'TodoIndex';

@Entry
@Component
struct Index {
  @State pendingList: TodoData[] = [];
  @State completedList: TodoData[] = [];
  @State showCompleted: boolean = true;
  @State inputText: string = '';

  aboutToAppear() {
    this.loadTodos();
  }

  onPageShow() {
    this.loadTodos();
  }

  private loadTodos() {
    TodoStore.loadTodos(getContext(this)).then((todos: TodoData[]) => {
      const pending: TodoData[] = [];
      const completed: TodoData[] = [];
      for (const item of todos) {
        if (item.done) {
          completed.push(item);
        } else {
          pending.push(item);
        }
      }
      this.pendingList = pending;
      this.completedList = completed;
    }).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'loadTodos error: %{public}s', JSON.stringify(error));
    });
  }

  private persistAndRefreshCards() {
    const context: Context = getContext(this);
    const todos: TodoData[] = this.pendingList.concat(this.completedList);
    TodoStore.saveTodos(context, todos).then(() => {
      return TodoStore.refreshAllCards(context, todos);
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
    this.pendingList = [todo].concat(this.pendingList);
    this.inputText = '';
    this.persistAndRefreshCards();
  }

  private toggleTodo(id: number) {
    const pendingNext: TodoData[] = [];
    const completedNext: TodoData[] = [];
    for (const item of this.pendingList) {
      if (item.id === id) {
        completedNext.push(new TodoData(item.id, item.text, true));
      } else {
        pendingNext.push(item);
      }
    }
    for (const item of this.completedList) {
      if (item.id === id) {
        pendingNext.push(new TodoData(item.id, item.text, false));
      } else {
        completedNext.push(item);
      }
    }
    this.pendingList = pendingNext;
    this.completedList = completedNext;
    this.persistAndRefreshCards();
  }

  private removeTodo(id: number) {
    const pendingNext: TodoData[] = [];
    const completedNext: TodoData[] = [];
    for (const item of this.pendingList) {
      if (item.id !== id) {
        pendingNext.push(item);
      }
    }
    for (const item of this.completedList) {
      if (item.id !== id) {
        completedNext.push(item);
      }
    }
    this.pendingList = pendingNext;
    this.completedList = completedNext;
    this.persistAndRefreshCards();
  }

  private clearCompleted() {
    this.completedList = [];
    this.persistAndRefreshCards();
  }

  @Builder
  private TodoItemRow(item: TodoData) {
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

  build() {
    Column() {
      Row() {
        Text('待办事项')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
        Text(`${this.pendingList.length} 项`)
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

      Scroll() {
        Column() {
          if (this.pendingList.length === 0) {
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
            .margin({ top: 40 })
          } else {
            Column({ space: 10 }) {
              ForEach(this.pendingList, (item: TodoData) => {
                this.TodoItemRow(item)
              }, (item: TodoData): string => item.id.toString())
            }
            .width('100%')
            .margin({ top: 16 })
          }

          if (this.completedList.length > 0) {
            Row() {
              Text('已完成')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Text(`${this.completedList.length} 项`)
                .fontSize(13)
                .fontColor(Color.Grey)
                .margin({ left: 8 })
              Blank()
              Text('清空')
                .fontSize(13)
                .fontColor('#FF4D4F')
                .padding({ left: 8, top: 4, bottom: 4 })
                .onClick(() => {
                  this.clearCompleted();
                })
              Text(this.showCompleted ? '收起' : '展开')
                .fontSize(13)
                .fontColor('#007DFF')
                .padding({ left: 12, top: 4, bottom: 4 })
                .onClick(() => {
                  this.showCompleted = !this.showCompleted;
                })
            }
            .width('100%')
            .margin({ top: 24, bottom: 10 })

            if (this.showCompleted) {
              Column({ space: 10 }) {
                ForEach(this.completedList, (item: TodoData) => {
                  this.TodoItemRow(item)
                }, (item: TodoData): string => item.id.toString())
              }
              .width('100%')
            }
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .margin({ top: 16 })
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F5F6FA')
  }
}
