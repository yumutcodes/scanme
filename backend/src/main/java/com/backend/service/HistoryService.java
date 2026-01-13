package com.backend.service;

import com.backend.dto.HistoryDto;
import com.backend.model.History;
import com.backend.model.User;
import com.backend.repository.HistoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class HistoryService {

    private final HistoryRepository historyRepository;
    private final UserService userService;

    public HistoryService(HistoryRepository historyRepository, UserService userService) {
        this.historyRepository = historyRepository;
        this.userService = userService;
    }

    public HistoryDto saveHistory(HistoryDto historyDto, String userEmail) {
        User user = userService.findUserByEmail(userEmail);

        History history = new History(
                historyDto.getBarcode(),
                historyDto.getProductName(),
                historyDto.getIsSafe(),
                historyDto.getScanDate(),
                user);

        History saved = historyRepository.save(history);

        return new HistoryDto(
                saved.getId(),
                saved.getBarcode(),
                saved.getProductName(),
                saved.getIsSafe(),
                saved.getScanDate());
    }

    public List<HistoryDto> getUserHistory(String userEmail) {
        User user = userService.findUserByEmail(userEmail);
        List<History> historyList = historyRepository.findByUserOrderByScanDateDesc(user);

        return historyList.stream()
                .map(h -> new HistoryDto(h.getId(), h.getBarcode(), h.getProductName(), h.getIsSafe(), h.getScanDate()))
                .collect(Collectors.toList());
    }

    public void deleteHistory(Long historyId, String userEmail) {
        User user = userService.findUserByEmail(userEmail);
        History history = historyRepository.findById(historyId)
                .orElseThrow(() -> new jakarta.persistence.EntityNotFoundException("History not found: " + historyId));

        // Verify ownership
        if (!history.getUser().getId().equals(user.getId())) {
            throw new SecurityException("User does not own this history entry");
        }

        historyRepository.delete(history);
    }
}
