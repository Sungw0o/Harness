package com.c203.app.global.response;

public record ApiResponse<T>(T data, Object meta) {

	public static <T> ApiResponse<T> of(T data) {
		return new ApiResponse<>(data, null);
	}
}
