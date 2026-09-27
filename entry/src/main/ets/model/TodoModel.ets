import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const CARD_DOMAIN = 0x0001;
const CARD_TAG = 'TodoStore';

export class TodoData {
  id: number;
  text: string;
  done: boolean;

  constructor(id: number, text: string, done: boolean) {
    this.id = id;
    this.text = text;
    this.done = done;
  }
}

interface TodoRawItem {
  id: number;
  text: string;
  done: boolean;
}

export class TodoStore {
  private static readonly STORE_NAME: string = 'todo_store';
  private static readonly KEY_TODOS: string = 'todo_list';
  private static readonly KEY_FORM_IDS: string = 'form_ids';

  private static async getStore(context: Context): Promise<preferences.Preferences> {
    await preferences.removePreferencesFromCache(context, TodoStore.STORE_NAME);
    return preferences.getPreferences(context, TodoStore.STORE_NAME);
  }

  static async loadTodos(context: Context): Promise<TodoData[]> {
    try {
      const store = await TodoStore.getStore(context);
      const raw = await store.get(TodoStore.KEY_TODOS, '[]');
      let rawStr = '[]';
      if (typeof raw === 'string') {
        rawStr = raw;
      }
      return TodoStore.parseTodos(rawStr);
    } catch {
      return [];
    }
  }

  static async saveTodos(context: Context, todos: TodoData[]): Promise<void> {
    const store = await TodoStore.getStore(context);
    const raw: string[] = [];
    for (const item of todos) {
      const rawItem: TodoRawItem = { id: item.id, text: item.text, done: item.done };
      raw.push(JSON.stringify(rawItem));
    }
    await store.put(TodoStore.KEY_TODOS, `[${raw.join(',')}]`);
    await store.flush();
  }

  static parseTodos(raw: string): TodoData[] {
    const result: TodoData[] = [];
    try {
      const parsed = JSON.parse(raw) as TodoRawItem[];
      if (Array.isArray(parsed)) {
        for (const item of parsed) {
          if (item !== null && typeof item.id === 'number' && typeof item.text === 'string' &&
            typeof item.done === 'boolean') {
            result.push(new TodoData(item.id, item.text, item.done));
          }
        }
      }
    } catch {
      return [];
    }
    return result;
  }

  static toggleDone(todos: TodoData[], id: number): TodoData[] {
    const next: TodoData[] = [];
    for (const item of todos) {
      if (item.id === id) {
        next.push(new TodoData(item.id, item.text, !item.done));
      } else {
        next.push(item);
      }
    }
    return next;
  }

  static async loadFormIds(context: Context): Promise<string[]> {
    try {
      const store = await TodoStore.getStore(context);
      const raw = await store.get(TodoStore.KEY_FORM_IDS, '[]');
      let rawStr = '[]';
      if (typeof raw === 'string') {
        rawStr = raw;
      }
      return TodoStore.parseFormIds(rawStr);
    } catch {
      return [];
    }
  }

  static async addFormId(context: Context, formId: string): Promise<void> {
    if (formId === '' || formId === 'temporary') {
      return;
    }
    const ids = await TodoStore.loadFormIds(context);
    if (!ids.includes(formId)) {
      ids.push(formId);
      await TodoStore.saveFormIds(context, ids);
    }
  }

  static async removeFormId(context: Context, formId: string): Promise<void> {
    const ids = await TodoStore.loadFormIds(context);
    const next: string[] = [];
    for (const id of ids) {
      if (id !== formId) {
        next.push(id);
      }
    }
    await TodoStore.saveFormIds(context, next);
  }

  private static async saveFormIds(context: Context, formIds: string[]): Promise<void> {
    const store = await TodoStore.getStore(context);
    await store.put(TodoStore.KEY_FORM_IDS, JSON.stringify(formIds));
    await store.flush();
  }

  private static parseFormIds(raw: string): string[] {
    const result: string[] = [];
    try {
      const parsed = JSON.parse(raw) as string[];
      if (Array.isArray(parsed)) {
        for (const id of parsed) {
          if (typeof id === 'string' && id !== '') {
            result.push(id);
          }
        }
      }
    } catch {
      return [];
    }
    return result;
  }

  static buildCardData(todos: TodoData[]): Record<string, Object> {
    const pending: TodoData[] = [];
    for (const item of todos) {
      if (!item.done) {
        pending.push(item);
      }
    }
    const visible: TodoData[] = pending.length > 0 ? pending : todos;
    const data: Record<string, Object> = {
      'todoCount': pending.length.toString(),
      'hasTodo': pending.length > 0 ? '1' : '0'
    };
    for (let i = 0; i < 3; i++) {
      const item: TodoData = i < visible.length ? visible[i] : new TodoData(0, '', false);
      data[`todo${i}Text`] = item.text;
      data[`todo${i}Id`] = item.id.toString();
      data[`todo${i}Done`] = item.done ? '1' : '0';
    }
    return data;
  }

  static refreshAllCards(context: Context, todos: TodoData[]): Promise<void> {
    const data = formBindingData.createFormBindingData(TodoStore.buildCardData(todos));
    return TodoStore.loadFormIds(context).then((formIds: string[]) => {
      const updates: Promise<void>[] = [];
      for (const formId of formIds) {
        updates.push(
          formProvider.updateForm(formId, data).catch((error: BusinessError) => {
            hilog.error(CARD_DOMAIN, CARD_TAG, 'updateForm error: %{public}s', JSON.stringify(error));
          })
        );
      }
      return Promise.all(updates).then(() => {});
    });
  }
}
