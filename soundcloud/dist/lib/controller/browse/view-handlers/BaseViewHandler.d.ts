import { ModelOf, ModelType } from '../../../model';
import { LoopFetchResult } from '../../../model/BaseModel';
import { QueueItem } from './ExplodableViewHandler';
import View, { PageRef } from './View';
import ViewHandler, { RenderedPage } from './ViewHandler';
import { RendererOf, RendererType } from './renderers';
import BaseRenderer, { RenderedListItem } from './renderers/BaseRenderer';
export default class BaseViewHandler<V extends View> implements ViewHandler {
    #private;
    constructor(uri: string, currentView: V, previousViews: View[]);
    browse(): Promise<RenderedPage>;
    explode(): Promise<QueueItem[]>;
    get uri(): string;
    get currentView(): V;
    get previousViews(): View[];
    protected getModel<T extends ModelType>(type: T): ModelOf<T>;
    protected getRenderer<T extends RendererType>(type: T): RendererOf<T>;
    protected constructPrevUri(): string;
    protected constructNextPageItem(data: PageRef | string): RenderedListItem;
    protected constructPageRef(pageToken?: string | null, pageOffset?: number): PageRef | null;
    protected addLinkToListTitle(title: string | undefined, link: string, linkText: string): string;
    protected buildPageFromLoopFetchResult<E>(result: LoopFetchResult<E>, renderer: BaseRenderer<E> | ((item: E) => BaseRenderer<E> | null), title?: string): RenderedPage;
}
//# sourceMappingURL=BaseViewHandler.d.ts.map