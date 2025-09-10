package com.example.webapp.controller;

import com.example.common_dataaccess.entity.Category;
import com.example.common_dataaccess.repository.CategoryRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    private final CategoryRepository repo;

    public CategoryController(CategoryRepository repo) {
        this.repo = repo;
    }

    @GetMapping
    public List<Category> getAll() {
        return repo.findAll();
    }

    @PostMapping
    public Category create(@RequestBody Category category) {
        return repo.save(category);
    }

    @PutMapping("/{id}")
    public Category update(@PathVariable Integer id, @RequestBody Category category) {
        category.setId(id);
        return repo.save(category);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        repo.deleteById(id);
    }
}
