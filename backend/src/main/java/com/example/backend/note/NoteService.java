package com.example.backend.note;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@RequiredArgsConstructor
@Service
public class NoteService {
    private final NoteRepository noteRepository;

    public NoteEntity save(NoteEntity noteEntity) {
        noteEntity.setDate(LocalDate.now());
        return noteRepository.save(noteEntity);
    }

    public List<NoteEntity> findByDate(LocalDate date) {
        return noteRepository.findByDate(date);
    }

    public void delete(Long id){
        noteRepository.deleteById(id);
    }

    public NoteEntity update(Long id, NoteEntity noteEntity) {
        NoteEntity note = noteRepository.findById(id).orElseThrow();
        note.setTitle(noteEntity.getTitle());
        note.setContent(noteEntity.getContent());
        return noteRepository.save(note);
    }

    public List<NoteRepository.DailyCount> counts(LocalDate from, LocalDate to) {
        return noteRepository.countByDateBetween(from, to);
    }
}
