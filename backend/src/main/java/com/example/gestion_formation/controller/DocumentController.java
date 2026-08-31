package com.example.gestion_formation.controller;

import com.example.gestion_formation.entity.Course;
import com.example.gestion_formation.entity.Document;
import com.example.gestion_formation.repository.CourseRepository;
import com.example.gestion_formation.repository.DocumentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/courses/{courseId}/documents")
@RequiredArgsConstructor
public class DocumentController {
    private final DocumentRepository documentRepository;
    private final CourseRepository courseRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')")
    public List<Document> list(@PathVariable Long courseId) {
        return documentRepository.findByCourseId(courseId);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')")
    public Document upload(@PathVariable Long courseId, @RequestParam("file") MultipartFile file) throws IOException {
        Course course = courseRepository.findById(courseId).orElseThrow();
        Document doc = Document.builder()
                .fileName(file.getOriginalFilename())
                .fileType(file.getContentType())
                .data(file.getBytes())
                .course(course)
                .build();
        return documentRepository.save(doc);
    }

    @GetMapping("/{docId}")
    @PreAuthorize("hasAnyRole('LEARNER','EMPLOYEE','ADMIN')")
    public ResponseEntity<byte[]> download(@PathVariable Long courseId, @PathVariable Long docId) {
        Document doc = documentRepository.findById(docId).orElseThrow();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(doc.getFileType()));
        headers.setContentDisposition(ContentDisposition.inline().filename(doc.getFileName()).build());
        return new ResponseEntity<>(doc.getData(), headers, HttpStatus.OK);
    }

    @DeleteMapping("/{docId}")
    @PreAuthorize("hasAnyRole('EMPLOYEE','ADMIN')")
    public void delete(@PathVariable Long courseId, @PathVariable Long docId) {
        documentRepository.deleteById(docId);
    }
}