package com.example.webapp.controller;

import com.example.common_dataaccess.repository.CategoryRepository;
import com.example.common_dataaccess.repository.ProductRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    private final ProductRepository productRepo;
    private final CategoryRepository categoryRepo;

    public HomeController(ProductRepository productRepo, CategoryRepository categoryRepo) {
        this.productRepo = productRepo;
        this.categoryRepo = categoryRepo;
    }

    @GetMapping("/")
    public String index() {
        return "index";
    }

    @GetMapping("/products-list")
    public String productsList(Model model) {
        model.addAttribute("productList", productRepo.findAll());
        return "products";
    }

    @GetMapping("/categories-list")
    public String categoriesList(Model model) {
        model.addAttribute("categoryList", categoryRepo.findAll());
        return "categories";
    }
}
