package com.example.webapp.controller;

import com.example.common.repository.ProductRepository;
import com.example.common.repository.CategoryRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
@RequestMapping("/admin")
public class AdminController {
    private final CategoryRepository categoryRepo;
    private final ProductRepository productRepo;

    public AdminController(CategoryRepository categoryRepo, ProductRepository productRepo) {
        this.categoryRepo = categoryRepo;
        this.productRepo = productRepo;
    }

    @GetMapping("/stats")
    public Map<String, Long> stats() {
        Map<String, Long> map = new HashMap<>();
        map.put("categories", categoryRepo.count());
        map.put("products", productRepo.count());
        return map;
    }
}
