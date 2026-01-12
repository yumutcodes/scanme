package com.backend.repository;

import com.backend.model.History;
import com.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HistoryRepository extends JpaRepository<History, Long> {
    List<History> findByUserOrderByScanDateDesc(User user);
}
