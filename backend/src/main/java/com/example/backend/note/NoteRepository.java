package com.example.backend.note;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;

public interface NoteRepository extends JpaRepository<NoteEntity, Long> {
    public List<NoteEntity> findByDate(LocalDate date);

    public interface DailyCount{
        LocalDate getDate();
        long getCount();
    }

    @Query("SELECT N.date as date, COUNT(N) as count " +
            "FROM NoteEntity N " +
            "WHERE N.date " +
            "BETWEEN :from AND :to " +
            "GROUP BY N.date")
    public List<DailyCount> countByDateBetween(LocalDate from, LocalDate to);
}
