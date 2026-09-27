import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window, router } from '@kit.ArkUI';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  private targetPage: string = 'main';

  private parseTarget(want: Want): string {
    const target = want.parameters?.['target'];
    if (typeof target === 'string' && target === 'add') {
      return 'add';
    }
    return 'main';
  }

  private navigateByTarget() {
    const state = router.getState();
    if (this.targetPage === 'add') {
      if (state.path === 'pages/AddTodo') {
        return;
      }
      router.pushUrl({ url: 'pages/AddTodo' }).catch(() => {
      });
    } else if (state.path !== 'pages/Index') {
      router.replaceUrl({ url: 'pages/Index' }).catch(() => {
      });
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'Ability onCreate');
    this.targetPage = this.parseTarget(want);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'Ability onNewWant');
    this.targetPage = this.parseTarget(want);
    this.navigateByTarget();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
      this.navigateByTarget();
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onBackground');
  }
}
