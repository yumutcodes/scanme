package com.backend.controller;

import com.backend.dto.HistoryDto;
import com.backend.service.HistoryService;
import com.backend.service.JwtService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/history")
public class HistoryController {

    private final HistoryService historyService;
    private final JwtService jwtService;

    public HistoryController(HistoryService historyService, JwtService jwtService) {
        this.historyService = historyService;
        this.jwtService = jwtService;
    }

    @PostMapping
    public ResponseEntity<HistoryDto> saveHistory(
            @RequestBody HistoryDto historyDto,
            @RequestHeader("Authorization") String token) {
        String email = jwtService.extractMail(token);
        HistoryDto saved = historyService.saveHistory(historyDto, email);
        return ResponseEntity.ok(saved);
    }

    @GetMapping
    public ResponseEntity<List<HistoryDto>> getHistory(
            @RequestHeader("Authorization") String token) {
        String email = jwtService.extractMail(token);
        List<HistoryDto> history = historyService.getUserHistory(email);
        return ResponseEntity.ok(history);
    }
}
