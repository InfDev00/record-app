package com.example.backend.note;

import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/notes")
public class NoteController {
    private final NoteService noteService;

    @PostMapping
    public NoteEntity create(@RequestBody NoteEntity note) {
        return noteService.save(note);
    }

    @GetMapping
    public List<NoteEntity> readByDate(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return noteService.findByDate(date);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        noteService.delete(id);
    }

    @PutMapping("/{id}")
    public NoteEntity update(@PathVariable Long id, @RequestBody NoteEntity note) {
        return noteService.update(id, note);
    }

    @GetMapping("/counts")
    public List<NoteRepository.DailyCount> counts(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return noteService.counts(from, to);
    }
}
