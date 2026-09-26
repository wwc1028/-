import { FormExtensionAbility, formBindingData } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'EntryFormAbility';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    hilog.info(DOMAIN, TAG, 'onAddForm');
    const formData: Record<string, string> = {
      'cardTitle': 'Hello World',
      'cardHint': '点击打开元服务'
    };
    return formBindingData.createFormBindingData(formData);
  }

  onUpdateForm(formId: string) {
    hilog.info(DOMAIN, TAG, 'onUpdateForm, formId: %{public}s', formId);
  }

  onFormEvent(formId: string, message: string) {
    hilog.info(DOMAIN, TAG, 'onFormEvent, formId: %{public}s, message: %{public}s', formId, message);
  }

  onRemoveForm(formId: string) {
    hilog.info(DOMAIN, TAG, 'onRemoveForm, formId: %{public}s', formId);
  }
}
