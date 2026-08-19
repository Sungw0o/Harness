package com.c203.app.domain.system.controller;

import java.util.Map;

import com.c203.app.global.response.ApiResponse;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/system")
public class SystemController {

	@GetMapping("/status")
	public ApiResponse<Map<String, String>> status() {
		return ApiResponse.of(Map.of("status", "ready"));
	}
}
