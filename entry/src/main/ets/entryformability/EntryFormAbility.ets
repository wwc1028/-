import { FormExtensionAbility, formBindingData, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { TodoData, TodoStore } from '../model/TodoModel';

const DOMAIN = 0x0000;
const TAG = 'EntryFormAbility';

interface CardAction {
  action: string;
  todoId: string;
}

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    hilog.info(DOMAIN, TAG, 'onAddForm');
    const formId = (want.parameters?.[formInfo.FormParam.IDENTITY_KEY] ?? '') as string;
    TodoStore.addFormId(this.context, formId).then(() => {
      return this.updateAllCards();
    }).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'onAddForm error: %{public}s', JSON.stringify(error));
    });
    return formBindingData.createFormBindingData(TodoStore.buildCardData([]));
  }

  onUpdateForm(formId: string) {
    hilog.info(DOMAIN, TAG, 'onUpdateForm, formId: %{public}s', formId);
    this.updateAllCards();
  }

  onFormEvent(formId: string, message: string) {
    hilog.info(DOMAIN, TAG, 'onFormEvent, formId: %{public}s, message: %{public}s', formId, message);
    let action: CardAction | undefined = undefined;
    try {
      action = JSON.parse(message) as CardAction;
    } catch {
      hilog.error(DOMAIN, TAG, 'invalid message: %{public}s', message);
      return;
    }
    if (action === null || action.action !== 'toggle' || typeof action.todoId !== 'string') {
      return;
    }
    const todoId: number = Number(action.todoId);
    TodoStore.loadTodos(this.context).then((todos: TodoData[]) => {
      const next = TodoStore.toggleDone(todos, todoId);
      return TodoStore.saveTodos(this.context, next).then(() => {
        return this.updateAllCards();
      });
    }).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'onFormEvent error: %{public}s', JSON.stringify(error));
    });
  }

  onRemoveForm(formId: string) {
    hilog.info(DOMAIN, TAG, 'onRemoveForm, formId: %{public}s', formId);
    TodoStore.removeFormId(this.context, formId).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'removeFormId error: %{public}s', JSON.stringify(error));
    });
  }

  private updateAllCards(): Promise<void> {
    return TodoStore.loadTodos(this.context).then((todos: TodoData[]) => {
      const data = formBindingData.createFormBindingData(TodoStore.buildCardData(todos));
      return TodoStore.loadFormIds(this.context).then((formIds: string[]) => {
        const updates: Promise<void>[] = [];
        for (const formId of formIds) {
          updates.push(
            formProvider.updateForm(formId, data).catch((error: BusinessError) => {
              hilog.error(DOMAIN, TAG, 'updateForm error: %{public}s', JSON.stringify(error));
            })
          );
        }
        return Promise.all(updates).then(() => {});
      });
    });
  }
}
