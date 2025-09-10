package com.example.webapp.controller;

import com.example.common.repository.ProductRepository;
import com.example.common.repository.CategoryRepository;
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
        return "index"; // index.html
    }

    @GetMapping("/products-list")
    public String productList(Model model) {
        model.addAttribute("productList", productRepo.findAll());
        return "products"; // products.html
    }

    @GetMapping("/categories-list")
    public String categoryList(Model model) {
        model.addAttribute("categoryList", categoryRepo.findAll());
        return "categories"; // categories.html (bạn phải tạo thêm)
    }
}
