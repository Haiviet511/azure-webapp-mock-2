package com.example.prj_app_mock.controller;

import com.example.prj_app_mock.entity.Category;
import com.example.prj_app_mock.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    @Autowired
    private CategoryRepository repo;

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
