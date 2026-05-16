package com.bomiq.sdm.exception;

import com.bomiq.sdm.dto.ApiResponse;
import jakarta.persistence.EntityNotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import java.util.stream.Collectors;

/**
 * Global exception handler for bomiq SDM.
 * Handles both REST API (JSON) and UI (Thymeleaf) error responses.
 */
@Slf4j
@ControllerAdvice
public class GlobalExceptionHandler {

    // ── REST API Errors (JSON) ─────────────────────────────────────────────────

    @ExceptionHandler(EntityNotFoundException.class)
    @ResponseBody
    public ResponseEntity<ApiResponse<Void>> handleEntityNotFound(EntityNotFoundException ex) {
        log.warn("Entity not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error("Not found: " + ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseBody
    public ResponseEntity<ApiResponse<Void>> handleValidation(MethodArgumentNotValidException ex) {
        String errors = ex.getBindingResult().getFieldErrors().stream()
                .map(fe -> fe.getField() + ": " + fe.getDefaultMessage())
                .collect(Collectors.joining("; "));
        log.warn("Validation failed: {}", errors);
        return ResponseEntity.badRequest()
                .body(ApiResponse.error("Validation failed: " + errors));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseBody
    public ResponseEntity<ApiResponse<Void>> handleIllegalArgument(IllegalArgumentException ex) {
        log.warn("Illegal argument: {}", ex.getMessage());
        return ResponseEntity.badRequest()
                .body(ApiResponse.error(ex.getMessage()));
    }

    // ── UI Errors (Thymeleaf) ─────────────────────────────────────────────────

    @ExceptionHandler({AccessDeniedException.class})
    public ModelAndView handleAccessDenied(AccessDeniedException ex) {
        log.warn("Access denied: {}", ex.getMessage());
        ModelAndView mv = new ModelAndView("error/403");
        mv.addObject("errorMessage", "You do not have permission to access this resource.");
        return mv;
    }

    @ExceptionHandler(Exception.class)
    public Object handleGeneral(Exception ex, jakarta.servlet.http.HttpServletRequest request) {
        log.error("Unhandled exception [{}]: {}", request.getRequestURI(), ex.getMessage(), ex);

        // If it's an API request, return JSON
        String acceptHeader = request.getHeader("Accept");
        if (acceptHeader != null && acceptHeader.contains("application/json")) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Internal server error: " + ex.getMessage()));
        }

        // Otherwise return error page
        ModelAndView mv = new ModelAndView("error/500");
        mv.addObject("errorMessage", ex.getMessage());
        mv.addObject("requestUri", request.getRequestURI());
        return mv;
    }
}
