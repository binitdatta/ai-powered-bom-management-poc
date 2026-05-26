import json
import logging
import time
from datetime import datetime, timezone
from typing import Any

logger = logging.getLogger("anthropic.audit")


def _serialize(obj: Any) -> Any:
    """Make Anthropic SDK objects JSON-serializable."""
    if hasattr(obj, "model_dump"):
        return obj.model_dump()
    if hasattr(obj, "__dict__"):
        return obj.__dict__
    return str(obj)


def log_anthropic_call(
    *,
    call_fn,                   # callable: the actual Anthropic SDK call
    request_label: str,        # e.g. "chat.handle_message"
    messages: list,
    model: str,
    system: str | None = None,
    max_tokens: int = 1024,
    stream: bool = False,
    extra_params: dict | None = None,
) -> Any:
    """
    Wraps any Anthropic messages.create() call with full audit logging.
    Logs the raw request payload and the raw response (or stream chunks).
    Returns whatever call_fn() returns so callers are unaffected.
    """
    request_payload = {
        "model": model,
        "max_tokens": max_tokens,
        "messages": messages,
        "stream": stream,
    }
    if system:
        request_payload["system"] = system
    if extra_params:
        request_payload.update(extra_params)

    request_id = f"{request_label}:{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%f')}"

    logger.info(
        "\n========== ANTHROPIC REQUEST [%s] ==========\n%s\n",
        request_id,
        json.dumps(request_payload, indent=2, default=_serialize),
    )

    start = time.perf_counter()
    try:
        response = call_fn(**request_payload)
    except Exception as exc:
        elapsed = time.perf_counter() - start
        logger.error(
            "\n========== ANTHROPIC ERROR [%s] (%.3fs) ==========\n%s\n",
            request_id,
            elapsed,
            str(exc),
        )
        raise

    elapsed = time.perf_counter() - start

    if stream:
        # Wrap the stream so we can log each chunk without buffering everything
        return _audited_stream(response, request_id, elapsed)
    else:
        logger.info(
            "\n========== ANTHROPIC RESPONSE [%s] (%.3fs) ==========\n%s\n",
            request_id,
            elapsed,
            json.dumps(_serialize(response), indent=2, default=_serialize),
        )
        return response


def _audited_stream(stream, request_id: str, first_chunk_elapsed: float):
    """
    Generator that yields SSE chunks from the Anthropic stream
    while logging each one.
    """
    chunks = []
    logger.info(
        "========== ANTHROPIC STREAM START [%s] (first chunk %.3fs) ==========",
        request_id,
        first_chunk_elapsed,
    )
    try:
        for chunk in stream:
            chunks.append(_serialize(chunk))
            logger.debug(
                "[%s] CHUNK: %s",
                request_id,
                json.dumps(_serialize(chunk), default=_serialize),
            )
            yield chunk
    finally:
        logger.info(
            "\n========== ANTHROPIC STREAM END [%s] — %d chunks ==========\n%s\n",
            request_id,
            len(chunks),
            json.dumps(chunks, indent=2, default=_serialize),
        )