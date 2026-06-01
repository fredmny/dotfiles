/**
 * Per-call and cumulative usage tracking for the Advisor extension.
 * State is persisted via pi.appendEntry so it survives compaction.
 */

export interface CallUsage {
  inputTokens: number;
  outputTokens: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
}

export interface SerializedUsage {
  callCount: number;
  totalInputTokens: number;
  totalOutputTokens: number;
  totalCacheRead: number;
  totalCacheWrite: number;
  totalCost: number;
}

export interface UsageTracker extends SerializedUsage {
  record(usage: CallUsage): void;
  restore(data: Partial<SerializedUsage>): void;
  toData(): SerializedUsage;
}

export function createUsageTracker(): UsageTracker {
  const t: UsageTracker = {
    callCount: 0,
    totalInputTokens: 0,
    totalOutputTokens: 0,
    totalCacheRead: 0,
    totalCacheWrite: 0,
    totalCost: 0,

    record(usage) {
      t.callCount += 1;
      t.totalInputTokens += usage.inputTokens ?? 0;
      t.totalOutputTokens += usage.outputTokens ?? 0;
      t.totalCacheRead += usage.cacheRead ?? 0;
      t.totalCacheWrite += usage.cacheWrite ?? 0;
      t.totalCost += usage.cost ?? 0;
    },

    restore(data) {
      t.callCount = data.callCount ?? 0;
      t.totalInputTokens = data.totalInputTokens ?? 0;
      t.totalOutputTokens = data.totalOutputTokens ?? 0;
      t.totalCacheRead = data.totalCacheRead ?? 0;
      t.totalCacheWrite = data.totalCacheWrite ?? 0;
      t.totalCost = data.totalCost ?? 0;
    },

    toData() {
      return {
        callCount: t.callCount,
        totalInputTokens: t.totalInputTokens,
        totalOutputTokens: t.totalOutputTokens,
        totalCacheRead: t.totalCacheRead,
        totalCacheWrite: t.totalCacheWrite,
        totalCost: t.totalCost,
      };
    },
  };
  return t;
}
