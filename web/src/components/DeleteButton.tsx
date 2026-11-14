"use client";

import { useActionState } from "react";
import { deleteRow, type FormState } from "@/app/crud-actions";
import { Icon } from "./Icon";

export function DeleteButton({ tableKey, id }: { tableKey: string; id: string }) {
  const [state, action, pending] = useActionState<FormState, FormData>(deleteRow.bind(null, tableKey, id), {
    error: null,
  });
  return (
    <form
      action={action}
      onSubmit={(e) => {
        if (!confirm(`Delete #${id}?`)) e.preventDefault();
      }}
      className="flex flex-col items-end"
    >
      <button className="btn-danger" disabled={pending}>
        <Icon name="trash" className="h-4 w-4" />
        {pending ? "Deleting…" : "Delete"}
      </button>
      {state.error && <p className="error mt-2 max-w-xs text-left">{state.error}</p>}
    </form>
  );
}
